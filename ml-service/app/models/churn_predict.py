"""
Churn Prediction Model (SaaS Focus)
Class-Based Implementation
Strategy: Analyze Transaction Volume Drop (Workshop -> Transactions)
"""
import os
import sys
import mysql.connector
from models import MLModel
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from utils.preprocessor import calculate_churn_features

class ChurnPredictionModel(MLModel):
    def predict(self):
        """
        Predict churn risk
        Logic: Workshops with dropping Transaction volume vs Previous Month
        """
        conn = None
        try:
            conn = mysql.connector.connect(**self.db_config)
            cursor = conn.cursor(dictionary=True)
            
            # DIRECT JOIN: Workshop -> Transactions (No Service dependency)
            query = """
            SELECT 
                w.id,
                w.name,
                u.name as owner,
                COALESCE(DATEDIFF(NOW(), MAX(t.created_at)), 999) as days_inactive,
                COUNT(CASE WHEN t.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as recent_count,
                COUNT(CASE WHEN t.created_at BETWEEN DATE_SUB(NOW(), INTERVAL 60 DAY) 
                                                AND DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as prev_count,
                COALESCE(AVG(t.amount), 0) as avg_transaction,
                COALESCE(sub.status, 'none') as membership_status
            FROM workshops w
            LEFT JOIN users u ON u.id = w.user_id
            LEFT JOIN transactions t ON t.workshop_uuid = w.id
            LEFT JOIN (
                SELECT user_id, status FROM owner_subscriptions 
                WHERE created_at = (
                    SELECT MAX(created_at) FROM owner_subscriptions AS sub2 WHERE sub2.user_id = owner_subscriptions.user_id
                )
            ) sub ON sub.user_id = u.id
            GROUP BY w.id, w.name, u.name, sub.status
            """
            
            cursor.execute(query)
            raw_data = cursor.fetchall()
            
            if not raw_data:
                return []
            
            # Calculate features (drop rate etc)
            processed_data = calculate_churn_features(raw_data)
            
            # Filter
            high_risk = []
            for row in processed_data:
                is_dropping = (row['drop_rate'] > 50 and row['prev_count'] > 0)
                is_expired = (row['membership_status'] == 'expired')
                
                if is_dropping or is_expired:
                    high_risk.append(row)
            
            if not high_risk:
                return []
                
            # Format results
            results = []
            for row in high_risk[:5]:
                val_drop = f"{row['drop_rate']:.0f}%"
                if row['membership_status'] == 'expired':
                    val_drop = "Expired"
                    
                results.append({
                    'name': row['name'],
                    'owner': row['owner'],
                    'drop_rate': val_drop,
                    'prev_vol': int(row['prev_count']),
                    'current_vol': int(row['recent_count'])
                })
                
            return results
            
        except Exception as e:
            print(f"Churn Prediction Error: {e}")
            import traceback
            traceback.print_exc()
            return []
        finally:
            if conn and conn.is_connected():
                conn.close()

    def train(self):
        pass
