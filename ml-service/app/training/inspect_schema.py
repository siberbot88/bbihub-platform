
import os
import mysql.connector
from dotenv import load_dotenv

env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(env_path)

DB_CONFIG = {
    'user': os.getenv('DB_USER', 'root'), 'password': os.getenv('DB_PASS', ''),
    'host': os.getenv('DB_HOST', 'localhost'), 'port': int(os.getenv('DB_PORT', 3306)),
    'database': os.getenv('DB_NAME', 'bbihub_core')
}

def inspect():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    print("--- TRANSACTIONS COLUMNS ---")
    cursor.execute("DESCRIBE transactions")
    for x in cursor.fetchall(): 
        # Print Field, Type, Null
        print(f"{x[0]} | Null: {x[2]}")
    conn.close()

if __name__ == '__main__':
    inspect()
