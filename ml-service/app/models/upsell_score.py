"""
Upsell Opportunity Scoring Model (SaaS Focus)
Class-Based Implementation
Strategy: Analyze Transaction Volume directly (Workshop -> Transactions)
"""
import os
import sys
import mysql.connector
from models import MLModel
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from utils.preprocessor import calculate_upsell_score

class UpsellScoringModel(MLModel):
    def predict(self):
        """
        Predict upsell opportunities (Targets for BBI Hub Plus)
        Logic: Owners with NO active subscription (or expired) but High Volume
        """
        conn = None
        try:
            conn = mysql.connector.connect(**self.db_config)
            cursor = conn.cursor(dictionary=True)
            
            # DIRECT JOIN: Workshop -> Transactions (No Services dependency)
            query = """
            SELECT 
                w.id,
                w.name,
                u.id as owner_id,
                u.name as owner,
                COUNT(t.id) as monthly_transactions,
                COALESCE(SUM(t.amount), 0) as total_revenue,
                COALESCE(sub.status, 'free') as membership_status
            FROM workshops w
            LEFT JOIN users u ON u.id = w.user_uuid
            LEFT JOIN transactions t ON t.workshop_uuid = w.id 
                                 AND t.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                                 AND t.status = 'success'
            LEFT JOIN (
                SELECT user_id, status FROM owner_subscriptions 
                WHERE created_at = (
                    SELECT MAX(created_at) FROM owner_subscriptions AS sub2 WHERE sub2.user_id = owner_subscriptions.user_id
                )
            ) sub ON sub.user_id = u.id
            GROUP BY w.id, w.name, u.id, u.name, sub.status
            HAVING total_revenue > 0
               AND (membership_status = 'free' OR membership_status = 'expired' OR membership_status = 'none' OR membership_status IS NULL)
            ORDER BY total_revenue DESC
            LIMIT 5
            """
            
            cursor.execute(query)
            raw_data = cursor.fetchall()
            
            if not raw_data:
                return []
            
            # Calculate scores
            processed_data = calculate_upsell_score(raw_data)
            
            # Sort by upsell_score desc
            processed_data.sort(key=lambda x: x['upsell_score'], reverse=True)
            
            # Format results
            results = []
            for row in processed_data[:5]:
                results.append({
                    'workshop_id': row['id'],
                    'workshop': row['name'],
                    'owner_id': row['owner_id'],
                    'owner': row['owner'],
                    'volume': int(row['monthly_transactions']),
                    'score': round(row['upsell_score'], 2)
                })
            
            return results
            
        except Exception as e:
            print(f"Upsell Scoring Error: {e}")
            import traceback
            traceback.print_exc()
            return []
        finally:
            if conn and conn.is_connected():
                conn.close()

    def train(self):
        pass
