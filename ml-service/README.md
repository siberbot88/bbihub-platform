# BBI Hub ML Service (Platform Business Outlook)

A dedicated Machine Learning microservice designed to power the **Platform Business Outlook (PBO)** dashboard for BBI Hub. This service provides real-time analytics, revenue forecasting, and predictive insights focusing on Workshop Partners (Mitra Bengkel).

## 🏗 Architecture & Design

Unlike traditional ML pipelines that rely on stale CSV exports, this service implements a **Direct Database Access** pattern.
*   **Real-Time Data**: Connects directly to the `bbihub_core` MySQL database.
*   **Class-Based Models**: Modular architecture (`models/*.py`) ensuring separation of concerns.
*   **Live Predictions**: MRR, Churn Risk, and Upsell Opportunities are calculated on-the-fly based on current subscription and transaction data.

## 🚀 Key Features

### 1. MRR Forecast (`MRRForecastModel`)
*   **Goal**: Predict Monthly Recurring Revenue flow from SaaS subscriptions.
*   **DataSource**: `owner_subscriptions` table.
*   **Logic**: Aggregates verified gross revenue and projects future trends using Linear Regression.

### 2. Churn Prediction (`ChurnPredictionModel`)
*   **Goal**: Identify workshops at risk of leaving the platform.
*   **DataSource**: `owner_subscriptions` & `transactions`.
*   **Logic**: Detects **Expired Subscriptions** (Immediate Risk) and **Volume Usage Drops** (>50% decrease in transaction volume vs previous month).

### 3. Upsell Opportunity Scoring (`UpsellScoringModel`)
*   **Goal**: Identify "Free Tier" workshops that should upgrade to "BBI Hub Plus".
*   **DataSource**: `workshops` & `transactions`.
*   **Logic**: Targets workshops with **High Transaction Volume** but **No Active Subscription**. These are high-value partners ready for monetization.

---

## 🛠 Installation & Setup

### Prerequisites
*   Python 3.9+
*   MySQL Database (bbihub_core)

### 1. Configuration (`.env`)
Create a `.env` file in the root directory:
```ini
DB_HOST=localhost
DB_PORT=3306
DB_NAME=bbihub_core
DB_USER=root
DB_PASS=
API_KEY=secret_key_here
PORT=5000
```

### 2. Install Dependencies
```bash
python -m venv venv
# Windows
.\venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

pip install -r requirements.txt
```

### 3. Run the Service
```bash
python app/main.py
```
> Service will run on `http://localhost:5000`

---

## 📊 Data Generation (Seeding)

Given the strict relational constraints of the database (Customer -> Vehicle -> Service -> Invoice -> Transaction), generating valid dummy data for Analytics requires robust tools. We provide two methods:

### Method A: Laravel Seeder (Recommended)
Uses standard Laravel Factories to ensure massive relational integrity.
```bash
cd ../backend
php artisan db:seed --class=OwnerAnalyticsSeeder
```
*   Generates 5 Active Owners (MRR)
*   Generates 1 Churn Candidate
*   *Note: Upsell data via Seeder is currently limited due to strict constraints. Recommended to use the App for simulating transactions.*

### Method B: Python Robust Seeder
A flexible script designed to bypass minor constraints for quick ML testing.
```bash
python app/training/seed_data.py
```

---

## 🔌 API Reference

### `GET /predict/platform-outlook`
Main endpoint consumed by the Admin Dashboard.

**Response Example:**
```json
{
    "mrr_forecast": {
        "prediction": 15000000,
        "growth_rate": 5.2,
        "history": [
            {"label": "Jan 2026", "y": 15000000}
        ]
    },
    "churn_candidates": [
        {
            "name": "Bengkel Jaya",
            "owner": "Budi Santoso",
            "reason": "Expired Subscription"
        }
    ],
    "upsell_candidates": [
        {
            "workshop": "Auto Fix Surabaya",
            "volume": 45,
            "score": 0.95
        }
    ]
}
```

### `POST /train/all`
(Optional) Trigger manual retraining of local model artifacts (if persistence is enabled).
**Header**: `X-API-Key: <your_key>`

---

## 📦 Project Structure
```
ml-service/
├── app/
│   ├── main.py              # Flask Entry Point
│   ├── models/              # Business Logic & ML Classes
│   │   ├── __init__.py      # Base MLModel class
│   │   ├── mrr_forecast.py
│   │   ├── churn_predict.py
│   │   └── upsell_score.py
│   ├── training/            # Seeding & Training Scripts
│   │   └── seed_data.py
│   └── utils/               # DB Helpers
├── requirements.txt
└── .env
```
