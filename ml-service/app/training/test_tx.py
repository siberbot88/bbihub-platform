
import os
import uuid
import mysql.connector
from dotenv import load_dotenv

env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(env_path)

DB_CONFIG = {
    'user': os.getenv('DB_USER', 'root'), 'password': os.getenv('DB_PASS', ''),
    'host': os.getenv('DB_HOST', 'localhost'), 'port': int(os.getenv('DB_PORT', 3306)),
    'database': os.getenv('DB_NAME', 'bbihub_core')
}

def test():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    try:
        # Create Workshop first (Needs Owner)
        u_id = str(uuid.uuid4())
        cursor.execute("INSERT INTO users (id, name, email, password, role) VALUES (%s, 'T', 't@t.com', 'x', 'owner')", (u_id,))
        
        w_id = str(uuid.uuid4())
        cursor.execute("INSERT INTO workshops (id, user_id, code, name, is_active) VALUES (%s, %s, 'W-T', 'WS', 1)", (w_id, u_id))
        
        # INSERT TRANSACTION WITH NULL SERVICE_UUID
        t_id = str(uuid.uuid4())
        # Inspect cols to see correct uuid names
        cursor.execute("DESCRIBE transactions")
        cols = [c[0] for c in cursor.fetchall()]
        print(f"Transactions cols: {cols}")
        
        sql = "INSERT INTO transactions (id, workshop_uuid, amount, status, created_at, updated_at) VALUES (%s, %s, 100000, 'success', NOW(), NOW())"
        
        # Check if service_uuid is in cols
        if 'service_uuid' in cols:
            print("Trying Insert without service_uuid...")
            cursor.execute(sql, (t_id, w_id))
            print("INSERT SUCCESS!")
            conn.commit()
        else:
            print("Cols mismatch?")

    except Exception as e:
        print(f"FAILED: {e}")
    finally:
        conn.close()

if __name__ == '__main__':
    test()
