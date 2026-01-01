import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
import mysql.connector
from datetime import datetime, timedelta

class WorkshopForecastModel:
    def __init__(self, db_config):
        self.db_config = db_config

    def predict(self, workshop_uuid, days=30):
        """
        Predict revenue for the next 'days' days.
        Returns:
            {
                'forecast': [
                    {'date': 'YYYY-MM-DD', 'predicted_revenue': float},
                    ...
                ],
                'trend': 'up' | 'down' | 'stable',
                'confidence': float (0-1)
            }
        """
        try:
            # 1. Fetch Historical Data (Last 90 days)
            conn = mysql.connector.connect(**self.db_config)
            query = """
                SELECT 
                    DATE(created_at) as date, 
                    SUM(amount) as revenue
                FROM transactions
                WHERE workshop_uuid = %s
                  AND status IN ('success', 'paid')
                  AND created_at >= DATE_SUB(NOW(), INTERVAL 90 DAY)
                GROUP BY DATE(created_at)
                ORDER BY date ASC
            """
            df = pd.read_sql(query, conn, params=(workshop_uuid,))
            conn.close()

            if df.empty:
                print(f"No historical data found for workshop {workshop_uuid}")
                return self._generate_dummy_forecast(days)

            # 2. Preprocessing
            df['date'] = pd.to_datetime(df['date'])
            # Fill missing dates with 0
            idx = pd.date_range(df['date'].min(), df['date'].max())
            df = df.set_index('date').reindex(idx, fill_value=0).reset_index()
            df.rename(columns={'index': 'date'}, inplace=True)

            # 3. Feature Engineering for Linear Regression
            # Convert date to ordinal (integer) for regression
            df['date_ordinal'] = df['date'].map(datetime.toordinal)

            # Prepare X and y
            X = df[['date_ordinal']]
            y = df['revenue']

            # 4. Train Model
            model = LinearRegression()
            model.fit(X, y)

            # 5. Forecast
            last_date = df['date'].max()
            future_dates = [last_date + timedelta(days=x) for x in range(1, days + 1)]
            future_ordinals = np.array([d.toordinal() for d in future_dates]).reshape(-1, 1)
            
            predictions = model.predict(future_ordinals)
            
            # Ensure no negative revenue prediction
            predictions = [max(0, float(p)) for p in predictions]

            # 6. Format Output
            forecast_list = []
            for date, pred in zip(future_dates, predictions):
                forecast_list.append({
                    'date': date.strftime('%Y-%m-%d'),
                    'value': round(pred, 2)
                })

            # Determine Trend
            slope = model.coef_[0]
            trend = 'stable'
            if slope > 1000: trend = 'up'
            elif slope < -1000: trend = 'down'
            
            print(f"Forecast generated successfully for workshop {workshop_uuid}: {len(forecast_list)} days")

            return {
                'forecast': forecast_list,
                'trend': trend,
                'slope': round(slope, 2),
                'history_count': len(df)
            }

        except Exception as e:
            print(f"Forecast Error: {e}")
            import traceback
            traceback.print_exc()
            print(f"Workshop UUID: {workshop_uuid}, Days: {days}")
            return self._generate_dummy_forecast(days)

    def _generate_dummy_forecast(self, days):
        """Fallback if no data exists"""
        start = datetime.now()
        data = []
        for i in range(days):
            date = start + timedelta(days=i+1)
            data.append({
                'date': date.strftime('%Y-%m-%d'),
                'value': 0
            })
        return {
            'forecast': data,
            'trend': 'stable',
            'slope': 0,
            'is_dummy': True
        }
