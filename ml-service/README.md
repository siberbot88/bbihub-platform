# ML Service for BBI Hub Platform Business Outlook

Python Flask microservice for Machine Learning predictions.

## Features

- **MRR Forecast**: Time-series prediction using Prophet
- **Churn Prediction**: Random Forest classifier for at-risk workshops
- **Upsell Scoring**: Logistic Regression for premium upgrade opportunities

## Setup

1. **Create virtual environment**
```bash
python -m venv venv
venv\Scripts\activate  # Windows
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure database**
Create `.env` file:
```
DB_HOST=localhost
DB_PORT=3306
DB_NAME=bbihub
DB_USER=root
DB_PASS=
API_KEY=your-secret-key
```

4. **Train initial models**
```bash
python app/training/train_mrr.py
python app/training/train_churn.py
python app/training/train_upsell.py
```

5. **Run service**
```bash
python app/main.py
# Service runs on http://localhost:5000
```

## API Endpoints

### GET `/predict/platform-outlook`
Returns ML predictions for PBO dashboard.

**Response:**
```json
{
  "mrr_forecast": {
    "prediction": 15000000,
    "growth_rate": 5.2,
    "history": [...]
  },
  "churn_candidates": [...],
  "upsell_candidates": [...]
}
```

### POST `/train/all`
Retrain all models with latest data.

**Headers:** `X-API-Key: your-secret-key`

## Production Deployment

Use Gunicorn for production:
```bash
gunicorn -w 4 -b 0.0.0.0:5000 app.main:app
```
