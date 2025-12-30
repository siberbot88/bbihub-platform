"""
Flask Application Main Entry Point
Refactored to use Class-Based ML Models
"""
from flask import Flask, jsonify, request
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

app = Flask(__name__)

# API Key authentication middleware
def require_api_key(f):
    from functools import wraps
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if api_key != os.getenv('API_KEY'):
            return jsonify({'error': 'Unauthorized'}), 401
        return f(*args, **kwargs)
    return decorated_function


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'ml-service'})


@app.route('/predict/platform-outlook', methods=['GET'])
def platform_outlook():
    """
    Main prediction endpoint for Platform Business Outlook
    Returns: MRR forecast, churn candidates, and upsell opportunities
    """
    try:
        from models.mrr_forecast import MRRForecastModel
        from models.churn_predict import ChurnPredictionModel
        from models.upsell_score import UpsellScoringModel
        
        # Build DB Config
        db_config = {
            'user': os.getenv('DB_USER', 'root'),
            'password': os.getenv('DB_PASS', ''),
            'host': os.getenv('DB_HOST', 'localhost'),
            'port': int(os.getenv('DB_PORT', 3306)),
            'database': os.getenv('DB_NAME', 'bbihub_core')
        }
        
        # Instantiate Models
        mrr_model = MRRForecastModel(db_config)
        churn_model = ChurnPredictionModel(db_config)
        upsell_model = UpsellScoringModel(db_config)
        
        # Get predictions
        mrr_data = mrr_model.predict()
        churn_data = churn_model.predict()
        upsell_data = upsell_model.predict()
        
        return jsonify({
            'mrr_forecast': mrr_data,
            'churn_candidates': churn_data,
            'upsell_candidates': upsell_data
        })
    
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return jsonify({'error': str(e)}), 500


@app.route('/train/all', methods=['POST'])
@require_api_key
def train_all_models():
    """
    Retrain all ML models with latest data
    Requires API key authentication
    """
    try:
        from training.train_mrr import train_mrr_model
        # from training.train_churn import train_churn_model
        # from training.train_upsell import train_upsell_model
        
        # Train all models
        mrr_result = train_mrr_model()
        # churn_result = train_churn_model()
        # upsell_result = train_upsell_model()
        
        return jsonify({
            'status': 'training_complete',
            'results': {
                'mrr': mrr_result,
                # 'churn': churn_result,
                # 'upsell': upsell_result
            }
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'False') == 'True'
    app.run(host='0.0.0.0', port=port, debug=debug)
