
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
            self.history_data = []
            for row in results:
                dates.append(row['month'])
                mrr_values.append(float(row['mrr']))
                
                # Format for API
                dt = datetime.strptime(row['month'], "%Y-%m-%d")
                self.history_data.append({
                    "label": dt.strftime('%b %Y'),
                    "y": float(row['mrr'])
                })
            
            # Simple Linear Regression Logic (Manual)
            X = [datetime.strptime(d, "%Y-%m-%d").timestamp() for d in dates]
            y = mrr_values
            
            n = len(X)
            if n < 2:
                print("Not enough data points for regression.")
                self.slope = 0
                self.intercept = 0
                return True # Return true but no regression

            sum_x = sum(X)
            sum_y = sum(y)
            sum_xy = sum(i*j for i, j in zip(X, y))
            sum_xx = sum(i*i for i in X)

            # Slope (m) and Intercept (b)
            denom = (n * sum_xx - sum_x**2)
            if denom == 0:
                print("Variance is zero, cannot regression.")
                self.slope = 0
                self.intercept = 0
                return True

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
        Predict MRR for next N months.
        Returns Dict matching legacy API structure.
        """
        # Auto-train for real-time
        self.train()

        # If no history, return empty
        if not hasattr(self, 'history_data') or not self.history_data:
             return {
                 "prediction": 0,
                 "growth_rate": 0,
                 "history": []
             }

        start_ts = datetime.now().timestamp()
        
        # Calculate Next Month Prediction
        # If possible, use last known date from history + 1 month
        # But simple logic uses current time
        future_ts = start_ts + (30 * 24 * 3600)
        next_month_val = self.slope * future_ts + self.intercept
        next_month_val = max(0, next_month_val)

        # Calculate Growth Rate
        monthly_growth = self.slope * (30 * 24 * 3600)
        current_val = self.slope * start_ts + self.intercept
        growth_rate = 0
        if current_val > 0:
            growth_rate = (monthly_growth / current_val) * 100
            
        return {
            "prediction": round(next_month_val, 2),
            "growth_rate": round(growth_rate, 2),
            "history": self.history_data  # Return ACTUAL history
        }

    def save(self):
        pass # Not persisting to file yet

    def load(self):
        pass
