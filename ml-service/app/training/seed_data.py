"""
Direct Data Seeder for ML Testing (SaaS Focus)
FINAL VERSION
- MRR (Owner Subscriptions)
- Churn (Expired)
- Upsell (Transactions DIRECTLY to Workshop)
"""
import os
import sys
import uuid
import random
from datetime import datetime, timedelta
import mysql.connector
from dotenv import load_dotenv

# Load env from parent directory
env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(env_path)

"""
NOTE ON DATA DEPENDENCY CHAIN:
The 'Upsell' (Transactions) seeding logic requires a full chain:
Customer -> Vehicle -> Service -> Invoice -> Transaction.
Due to strict Database Constraints (Foreign Keys on Invoices, Customers, etc),
injecting 'Dummy' transactions via raw SQL is fragile.

Current Status:
- MRR (Subs): WORKING.
- Churn (Expired): WORKING.
- Upsell (Sales): Skipped in Seeder. Will populate naturally via App Usage.
"""

DB_CONFIG = {
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASS', ''),
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'database': os.getenv('DB_NAME', 'bbihub_core')
}

def seed_saas_data():
    print(f"Connecting to DB {DB_CONFIG['database']} at {DB_CONFIG['host']}...")
    conn = None
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # --- PREP: Spatie Role ID ---
        owner_role_id = None
        try:
            cursor.execute("SELECT id FROM roles WHERE name = 'owner'")
            res = cursor.fetchone()
            if res: owner_role_id = res[0]
        except: pass
        
        # --- PREP: User Columns ---
        cursor.execute("DESCRIBE users")
        u_cols = {col[0] for col in cursor.fetchall()}
        
        # --- PREP: Workshop Columns ---
        cursor.execute("DESCRIBE workshops")
        w_cols = {col[0] for col in cursor.fetchall()}
        
        # --- PREP: Transaction Columns ---
        cursor.execute("DESCRIBE transactions")
        t_cols = {col[0] for col in cursor.fetchall()}

        # 1. SUBSCRIPTION PLANS
        try:
            cursor.execute("SELECT id FROM subscription_plans WHERE code = 'bbi_hub_plus'")
            res = cursor.fetchone()
            if res: plan_id = res[0]
            else:
                plan_id = str(uuid.uuid4())
                cursor.execute("INSERT INTO subscription_plans (id, code, name, description, price_monthly, price_yearly, features, is_active, is_recommended, created_at, updated_at) VALUES (%s, 'bbi_hub_plus', 'Plus', 'Desc', 120000, 1440000, '{}', 1, 1, NOW(), NOW())", (plan_id,))
                conn.commit()
        except Exception as e:
            print(f"Plan Error: {e}"); return

        # 2. MRR (Users + Subs)
        print("Seeding MRR...")
        try:
            for i in range(5):
                 u_id = str(uuid.uuid4())
                 suffix = u_id[:6]
                 u_data = {'id': u_id, 'name': 'SaaS Owner', 'email': f'saas_{suffix}@t.com', 'password': 'x', 'created_at': datetime.now(), 'updated_at': datetime.now()}
                 if 'role' in u_cols: u_data['role'] = 'owner'
                 if 'username' in u_cols: u_data['username'] = f'saas_{suffix}'
                 
                 cols = ', '.join(u_data.keys())
                 vals = ', '.join(['%s']*len(u_data))
                 cursor.execute(f"INSERT INTO users ({cols}) VALUES ({vals})", list(u_data.values()))
                 
                 if owner_role_id:
                     try: cursor.execute("INSERT INTO model_has_roles (role_id, model_type, model_id) VALUES (%s, 'App\\\\Models\\\\User', %s)", (owner_role_id, u_id))
                     except: pass
            conn.commit()
            
            cursor.execute("SELECT id FROM users WHERE email LIKE 'saas_%' LIMIT 50")
            user_ids = [r[0] for r in cursor.fetchall()]
            
            count_inserted = 0
            for uid in user_ids:
                if random.random() < 0.5: continue
                sub_id = str(uuid.uuid4())
                starts = datetime.now() - timedelta(days=random.randint(0, 300))
                sql = "INSERT INTO owner_subscriptions (id, user_id, plan_id, status, billing_cycle, starts_at, expires_at, gross_amount, payment_type, created_at, updated_at) VALUES (%s, %s, %s, 'active', 'monthly', %s, %s, 120000, 'cc', %s, %s)"
                cursor.execute(sql, (sub_id, uid, plan_id, starts, starts+timedelta(days=30), starts, starts))
                count_inserted += 1
            conn.commit()
            print(f"MRR Seeded: {count_inserted}")
        except Exception as e: print(f"MRR Error: {e}")

        # 3. CHURN (Expired)
        print("Seeding Churn (Expired)...")
        try:
            suffix = str(uuid.uuid4().hex)[:6]
            u_ch = str(uuid.uuid4())
            u_data = {'id': u_ch, 'name': f'Churn {suffix}', 'email': f'churn_{suffix}@t.com', 'password': 'x', 'created_at': datetime.now(), 'updated_at': datetime.now()}
            if 'role' in u_cols: u_data['role'] = 'owner'
            if 'username' in u_cols: u_data['username'] = f'churn_{suffix}'
            cols = ', '.join(u_data.keys())
            vals = ', '.join(['%s']*len(u_data))
            cursor.execute(f"INSERT INTO users ({cols}) VALUES ({vals})", list(u_data.values()))
            
            if owner_role_id:
                 try: cursor.execute("INSERT INTO model_has_roles (role_id, model_type, model_id) VALUES (%s, 'App\\\\Models\\\\User', %s)", (owner_role_id, u_ch))
                 except: pass

            s_ch = str(uuid.uuid4())
            exp = datetime.now() - timedelta(days=2)
            cursor.execute("INSERT INTO owner_subscriptions (id, user_id, plan_id, status, billing_cycle, starts_at, expires_at, gross_amount, payment_type, created_at, updated_at) VALUES (%s, %s, %s, 'expired', 'monthly', %s, %s, 120000, 'cc', %s, %s)", (s_ch, u_ch, plan_id, exp-timedelta(days=30), exp, exp, exp))
            conn.commit()
            print("Churn Seeded.")
        except Exception as e: print(f"Churn Error: {e}")

        # 4. UPSELL (Transactions)
        print("Seeding Upsell (Transactions)...")
        try:
            suffix = str(uuid.uuid4().hex)[:6]
            u_up = str(uuid.uuid4())
            u_data = {'id': u_up, 'name': f'Upsell {suffix}', 'email': f'up_{suffix}@t.com', 'password': 'x', 'created_at': datetime.now(), 'updated_at': datetime.now()}
            if 'role' in u_cols: u_data['role'] = 'owner'
            if 'username' in u_cols: u_data['username'] = f'up_{suffix}'
            cols = ', '.join(u_data.keys())
            vals = ', '.join(['%s']*len(u_data))
            cursor.execute(f"INSERT INTO users ({cols}) VALUES ({vals})", list(u_data.values()))
            
            if owner_role_id:
                 try: cursor.execute("INSERT INTO model_has_roles (role_id, model_type, model_id) VALUES (%s, 'App\\\\Models\\\\User', %s)", (owner_role_id, u_up))
                 except: pass

            # Workshop (Clean)
            w_up = str(uuid.uuid4())
            w_data = {'id': w_up, 'code': f'UP-{suffix}', 'name': f'WS Upsell {suffix}', 'is_active': 1, 'created_at': datetime.now(), 'updated_at': datetime.now()}
            if 'user_uuid' in w_cols: w_data['user_uuid'] = u_up
            else: w_data['user_id'] = u_up
            
            cols = ', '.join(w_data.keys())
            vals = ', '.join(['%s']*len(w_data))
            cursor.execute(f"INSERT INTO workshops ({cols}) VALUES ({vals})", list(w_data.values()))
            
            # Transactions (Direct)
            for _ in range(15):
                t_id = str(uuid.uuid4())
                t_data = {'id': t_id, 'amount': 150000, 'status': 'success', 'created_at': datetime.now(), 'updated_at': datetime.now()}
                if 'workshop_uuid' in t_cols: t_data['workshop_uuid'] = w_up
                elif 'workshop_id' in t_cols: t_data['workshop_id'] = w_up
                # Note: Assuming service_uuid is NULLABLE and omitted
                
                cols = ', '.join(t_data.keys())
                vals = ', '.join(['%s']*len(t_data))
                cursor.execute(f"INSERT INTO transactions ({cols}) VALUES ({vals})", list(t_data.values()))

            conn.commit()
            print("Upsell Data Seeded (Transactions Direct).")
            
        except Exception as e:
            print(f"Upsell Error: {e}")

    except Exception as e:
        print(f"Global: {e}")
    finally:
        if conn and conn.is_connected():
            conn.close()

if __name__ == '__main__':
    seed_saas_data()
