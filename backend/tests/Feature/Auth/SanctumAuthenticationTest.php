<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class SanctumAuthenticationTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();

        // Create roles
        Role::firstOrCreate(['name' => 'owner', 'guard_name' => 'sanctum']);
        Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'sanctum']);
        Role::firstOrCreate(['name' => 'mechanic', 'guard_name' => 'sanctum']);

        // Create test user
        $this->user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => Hash::make('password123!'),
        ]);
        $this->user->guard_name = 'sanctum';
        $this->user->assignRole('owner');
    }

    /**
     * Test: User dapat register dan menerima token
     */
    public function test_register_creates_user_and_returns_token()
    {
        $response = $this->postJson(route('api.register'), [
            'name' => 'New User',
            'username' => 'newuser',
            'email' => 'newuser@example.com',
            'password' => 'UniqueBBIHUB2025!@#$%',
            'password_confirmation' => 'UniqueBBIHUB2025!@#$%',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'access_token',
                    'token_type',
                    'user' => [
                        'id',
                        'name',
                        'email',
                        'username',
                        'roles',
                    ],
                ],
            ]);

        // Verify token is valid
        $this->assertNotEmpty($response->json('data.access_token'));
        $this->assertEquals('Bearer', $response->json('data.token_type'));

        // Verify user was created
        $this->assertDatabaseHas('users', [
            'email' => 'newuser@example.com',
            'username' => 'newuser',
        ]);
    }

    /**
     * Test: User dapat login dan menerima token
     */
    public function test_login_returns_valid_token()
    {
        $response = $this->postJson(route('api.login'), [
            'email' => 'test@example.com',
            'password' => 'password123!',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'access_token',
                    'token_type',
                    'remember',
                    'expires_in',
                    'user',
                ],
            ]);

        $this->assertNotEmpty($response->json('data.access_token'));
    }

    /**
     * Test: Token dapat digunakan untuk mengakses protected route
     */
    public function test_token_can_access_protected_routes()
    {
        // Login to get token
        $loginResponse = $this->postJson(route('api.login'), [
            'email' => 'test@example.com',
            'password' => 'password123!',
        ]);

        $token = $loginResponse->json('data.access_token');

        // Access protected route with token
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson(route('api.user'));

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'name',
                    'email',
                ],
            ]);
    }

    /**
     * Test: Akses tanpa token ditolak
     */
    public function test_protected_route_without_token_is_rejected()
    {
        $response = $this->getJson(route('api.user'));

        $response->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);
    }

    /**
     * Test: Token invalid ditolak
     */
    public function test_invalid_token_is_rejected()
    {
        $response = $this->withHeader('Authorization', 'Bearer invalid-token-12345')
            ->getJson(route('api.user'));

        $response->assertStatus(401);
    }

    /**
     * Test: Logout menghapus current token
     */
    public function test_logout_deletes_current_token()
    {
        // Login to get token
        $loginResponse = $this->postJson(route('api.login'), [
            'email' => 'test@example.com',
            'password' => 'password123!',
        ]);

        $token = $loginResponse->json('data.access_token');
        $tokenId = explode('|', $token)[0];

        // Verify token exists in database
        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $tokenId,
            'tokenable_id' => $this->user->id,
        ]);

        // Logout
        $logoutResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson(route('api.logout'));

        $logoutResponse->assertStatus(200);

        // Verify token is deleted from database
        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $tokenId,
        ]);

        // Verify findToken returns null
        $this->assertNull(PersonalAccessToken::findToken($token));
    }

    /**
     * Test: Logout dengan parameter all=true menghapus semua token
     */
    public function test_logout_all_deletes_all_tokens()
    {
        // Create multiple tokens
        $token1 = $this->user->createToken('device1')->plainTextToken;
        $token2 = $this->user->createToken('device2')->plainTextToken;
        $token3 = $this->user->createToken('device3')->plainTextToken;

        // Verify all tokens exist
        $this->assertNotNull(PersonalAccessToken::findToken($token1));
        $this->assertNotNull(PersonalAccessToken::findToken($token2));
        $this->assertNotNull(PersonalAccessToken::findToken($token3));

        // Logout all with token1
        $response = $this->withHeader('Authorization', 'Bearer ' . $token1)
            ->postJson(route('api.logout'), ['all' => true]);

        $response->assertStatus(200);

        // Verify all tokens are deleted
        $this->assertNull(PersonalAccessToken::findToken($token1));
        $this->assertNull(PersonalAccessToken::findToken($token2));
        $this->assertNull(PersonalAccessToken::findToken($token3));
    }

    /**
     * Test: Login dengan remember=true membuat token dengan expiration
     */
    public function test_remember_me_creates_long_lived_token()
    {
        $response = $this->postJson(route('api.login'), [
            'email' => 'test@example.com',
            'password' => 'password123!',
            'remember' => true,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'remember' => true,
                    'expires_in' => '30 days',
                ],
            ]);

        $token = $response->json('data.access_token');
        $personalAccessToken = PersonalAccessToken::findToken($token);

        $this->assertNotNull($personalAccessToken);
        $this->assertNotNull($personalAccessToken->expires_at);
        $this->assertTrue($personalAccessToken->expires_at->isFuture());
    }

    /**
     * Test: Login dengan revoke_others=true menghapus token lain
     */
    public function test_revoke_others_deletes_previous_tokens()
    {
        // Create existing tokens
        $oldToken = $this->user->createToken('old_device')->plainTextToken;
        $this->assertNotNull(PersonalAccessToken::findToken($oldToken));

        // Login with revoke_others
        $response = $this->postJson(route('api.login'), [
            'email' => 'test@example.com',
            'password' => 'password123!',
            'revoke_others' => true,
        ]);

        $response->assertStatus(200);

        // Verify old token is deleted
        $this->assertNull(PersonalAccessToken::findToken($oldToken));

        // Verify new token works
        $newToken = $response->json('data.access_token');
        $userResponse = $this->withHeader('Authorization', 'Bearer ' . $newToken)
            ->getJson(route('api.user'));

        $userResponse->assertStatus(200);
    }

    /**
     * Test: Token memiliki abilities yang benar
     */
    public function test_token_has_correct_abilities()
    {
        $token = $this->user->createToken('test_token', ['*'])->plainTextToken;
        $personalAccessToken = PersonalAccessToken::findToken($token);

        $this->assertNotNull($personalAccessToken);
        $this->assertTrue($personalAccessToken->can('*'));
    }

    /**
     * Test: Change password dengan token yang valid
     */
    public function test_change_password_with_valid_token()
    {
        $token = $this->user->createToken('test_token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson(route('api.change-password'), [
                'current_password' => 'password123!',
                'new_password' => 'NewSecurePassword456!',
                'new_password_confirmation' => 'NewSecurePassword456!',
            ]);

        $response->assertStatus(200);

        // Verify password was changed
        $this->user->refresh();
        $this->assertTrue(Hash::check('NewSecurePassword456!', $this->user->password));
    }

    /**
     * Test: Multiple concurrent tokens untuk user yang sama
     */
    public function test_multiple_concurrent_tokens_work_independently()
    {
        // Create tokens for different devices
        $mobileToken = $this->user->createToken('mobile_device')->plainTextToken;
        $webToken = $this->user->createToken('web_device')->plainTextToken;
        $tabletToken = $this->user->createToken('tablet_device')->plainTextToken;

        $mobileTokenId = explode('|', $mobileToken)[0];
        $webTokenId = explode('|', $webToken)[0];
        $tabletTokenId = explode('|', $tabletToken)[0];

        // Verify all tokens work
        $response1 = $this->withHeader('Authorization', 'Bearer ' . $mobileToken)
            ->getJson(route('api.user'));
        $response1->assertStatus(200);

        $response2 = $this->withHeader('Authorization', 'Bearer ' . $webToken)
            ->getJson(route('api.user'));
        $response2->assertStatus(200);

        $response3 = $this->withHeader('Authorization', 'Bearer ' . $tabletToken)
            ->getJson(route('api.user'));
        $response3->assertStatus(200);

        // Verify all tokens exist in database
        $this->assertDatabaseHas('personal_access_tokens', ['id' => $mobileTokenId]);
        $this->assertDatabaseHas('personal_access_tokens', ['id' => $webTokenId]);
        $this->assertDatabaseHas('personal_access_tokens', ['id' => $tabletTokenId]);

        // Delete one token
        $pat = PersonalAccessToken::findToken($mobileToken);
        $pat->delete();

        // Verify deleted token is removed from database
        $this->assertDatabaseMissing('personal_access_tokens', ['id' => $mobileTokenId]);

        // Verify findToken returns null for deleted token
        $this->assertNull(PersonalAccessToken::findToken($mobileToken));

        // Verify other tokens still exist in database
        $this->assertDatabaseHas('personal_access_tokens', ['id' => $webTokenId]);
        $this->assertDatabaseHas('personal_access_tokens', ['id' => $tabletTokenId]);

        // Verify other tokens still work
        $response5 = $this->withHeader('Authorization', 'Bearer ' . $webToken)
            ->getJson(route('api.user'));
        $response5->assertStatus(200);
    }

    /**
     * Test: Role-based access dengan Sanctum
     */
    public function test_role_based_access_control()
    {
        // Create admin user
        $admin = User::factory()->create([
            'email' => 'admin@example.com',
            'password' => Hash::make('password123'),
        ]);
        $admin->guard_name = 'sanctum';
        $admin->assignRole('admin');

        $adminToken = $admin->createToken('admin_token')->plainTextToken;

        // Admin can access admin routes
        $response = $this->withHeader('Authorization', 'Bearer ' . $adminToken)
            ->getJson('/api/v1/admins/dashboard/stats');

        // Should not be 401 (Unauthenticated)
        $this->assertNotEquals(401, $response->status());
    }

    /**
     * Test: Token expiration untuk remember token
     */
    public function test_expired_token_is_rejected()
    {
        // Create token with past expiration
        $token = $this->user->createToken('test_token', ['*'], now()->subDay());

        $personalAccessToken = PersonalAccessToken::findToken($token->plainTextToken);

        // Manually set expired date
        $personalAccessToken->expires_at = now()->subDay();
        $personalAccessToken->save();

        // Try to use expired token
        $response = $this->withHeader('Authorization', 'Bearer ' . $token->plainTextToken)
            ->getJson(route('api.user'));

        $response->assertStatus(401);
    }

    /**
     * Test: Sanctum guard configuration
     */
    public function test_sanctum_guard_is_configured_correctly()
    {
        $this->assertEquals(['web'], config('sanctum.guard'));
        $this->assertNull(config('sanctum.expiration'));
    }
}
