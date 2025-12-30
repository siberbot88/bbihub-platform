
import mysql.connector
import os
from datetime import datetime
import json
from . import MLModel

class MRRForecastModel(MLModel):
    def __init__(self, db_config=None):
        self.db_config = db_config
        self.slope = 0
        self.intercept = 0

    def train(self):
        """
        Train the MRR model using historical data from owner_subscriptions (SaaS Revenue).
        """
        if not self.db_config:
            raise ValueError("Database configuration not set.")

        try:
            conn = mysql.connector.connect(**self.db_config)
            cursor = conn.cursor(dictionary=True)

            # Fetch monthly revenue from owner subscriptions (paid)
            query = """
                SELECT 
                    DATE_FORMAT(starts_at, '%Y-%m-01') as month, 
                    SUM(gross_amount) as mrr
                FROM owner_subscriptions
                WHERE status IN ('active', 'expired') 
                GROUP BY month
                ORDER BY month ASC
            """
            cursor.execute(query)
            results = cursor.fetchall()
            
            if not results:
                print("No data found in owner_subscriptions.")
                return False
                
            dates = []
            mrr_values = []
            
            for row in results:
                dates.append(row['month'])
                mrr_values.append(float(row['mrr']))
            
            # Simple Linear Regression Logic (Manual)
            X = [datetime.strptime(d, "%Y-%m-%d").timestamp() for d in dates]
            y = mrr_values
            
            n = len(X)
            if n < 2:
                print("Not enough data points for regression.")
                return False

            sum_x = sum(X)
            sum_y = sum(y)
            sum_xy = sum(i*j for i, j in zip(X, y))
            sum_xx = sum(i*i for i in X)

            # Slope (m) and Intercept (b)
            # Denominator check to avoid div by zero
            denom = (n * sum_xx - sum_x**2)
            if denom == 0:
                print("Variance is zero, cannot regression.")
                return False

            self.slope = (n * sum_xy - sum_x * sum_y) / denom
            self.intercept = (sum_y - self.slope * sum_x) / n
            
            print(f"Model trained. Slope: {self.slope}, Intercept: {self.intercept}")
            return True

        except mysql.connector.Error as err:
            print(f"Error: {err}")
            return False
        finally:
            if 'conn' in locals() and conn.is_connected():
                cursor.close()
                conn.close()

    def predict(self, months_ahead=3):
        """
        Predict MRR for next N months
        """
        if self.slope == 0 and self.intercept == 0:
             # Try simple fallback if not trained but we have data?
             # No, just return zero if untested
             return []

        future_mrr = []
        current_date = datetime.now()
        
        for i in range(1, months_ahead + 1):
            future_date = datetime(current_date.year, current_date.month, 1) # Simplification
            # Move month ahead? Logic is simple timestamp
            # Better: get timestamps for future dates
            # This manual linear regression is naive but works for demo
            
            # TODO: Improve date handling
            pass 
        
        # Simpler approach: return linear projection for simple chart
        # We return [ {month: '...', value: 123}, ...]
        
        predictions = []
        import calendar
        
        # Get last month from DB to continue? Or just use current time?
        # Let's use current time as X start
        
        start_ts = datetime.now().timestamp()
        
        for i in range(1, months_ahead + 1):
            # Add i months roughly
            future_ts = start_ts + (i * 30 * 24 * 3600) 
            pred_value = self.slope * future_ts + self.intercept
            
            # Format month
            future_dt = datetime.fromtimestamp(future_ts)
            month_str = future_dt.strftime('%b %Y')
            
            predictions.append({
                "month": month_str,
                "value": round(max(0, pred_value), 2)
            })
            
        return predictions

    def save(self):
        pass # Not persisting to file yet

    def load(self):
        pass
