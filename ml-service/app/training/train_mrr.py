
import mysql.connector
import sys
import os
from dotenv import load_dotenv

# Add parent dir to path for imports if needed
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from app.models.mrr_forecast import MRRForecastModel

# Load env
env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '.env')
load_dotenv(env_path)

DB_CONFIG = {
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASS', ''),
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'database': os.getenv('DB_NAME', 'bbihub_core')
}

def train_mrr():
    print("Training MRR Model...")
    
    # Check if data exists in owner_subscriptions
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        query = "SELECT COUNT(*) FROM owner_subscriptions WHERE status IN ('active', 'expired')"
        cursor.execute(query)
        count = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        
        if count < 5:
            print(f"Not enough data to train MRR model (found {count}, need 5+). Run seeder.")
            return
    except Exception as e:
        print(f"DB Error: {e}")
        return

    model = MRRForecastModel(DB_CONFIG)
    success = model.train()
    
    if success:
        print("MRR Model trained successfully based on Owner Subscriptions.")
    else:
        print("Failed to train MRR Model.")

if __name__ == "__main__":
    train_mrr()
