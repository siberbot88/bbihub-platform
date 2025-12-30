"""
Data Preprocessing Utilities
Pure Python Implementation (No Pandas/Numpy)
"""
from datetime import datetime, timedelta

def prepare_mrr_data(raw_data):
    """
    Prepare MRR data from list of dicts
    
    Args:
        raw_data: List of dicts with 'month' and 'mrr' keys
    
    Returns:
        list: Sorted list of dicts [{'ds': datetime, 'y': float}, ...]
    """
    if not raw_data:
        return []
    
    formatted_data = []
    for row in raw_data:
        # Assuming month is YYYY-MM-DD string
        try:
            if isinstance(row['month'], str):
                ds = datetime.strptime(row['month'], '%Y-%m-%d')
            else:
                ds = row['month']
            
            formatted_data.append({
                'ds': ds,
                'y': float(row['mrr'])
            })
        except Exception as e:
            print(f"Skipping row {row}: {e}")
            continue
            
    # Sort by date
    formatted_data.sort(key=lambda x: x['ds'])
    
    return formatted_data


def calculate_churn_features(workshop_data):
    """
    Calculate churn prediction features (Pure Python)
    
    Args:
        workshop_data: List of workshop dictionaries
    
    Returns:
        list: List of dicts with added features
    """
    if not workshop_data:
        return []
        
    processed = []
    for row in workshop_data:
        new_row = row.copy()
        
        # Handle None/Null values
        prev_count = float(row.get('prev_count') or 0)
        recent_count = float(row.get('recent_count') or 0)
        
        # Calculate drop rate
        if (prev_count + 1) == 0:
            drop_rate = 0
        else:
            drop_rate = ((prev_count - recent_count) / (prev_count + 1)) * 100
            
        new_row['drop_rate'] = drop_rate
        
        # Membership status check
        status = row.get('membership_status')
        new_row['has_membership'] = 1 if status in ['active', 'premium'] else 0
        
        processed.append(new_row)
        
    return processed


def calculate_upsell_score(workshop_data):
    """
    Calculate upsell opportunity score (Pure Python)
    
    Args:
        workshop_data: List of workshop dictionaries
    
    Returns:
        list: processed data with scores
    """
    if not workshop_data:
        return []
        
    processed = []
    for row in workshop_data:
        new_row = row.copy()
        
        # Get raw values
        monthly_trans = float(row.get('monthly_transactions') or 0)
        total_rev = float(row.get('total_revenue') or 0)
        
        # Calculate scores
        volume_score = monthly_trans / 50
        revenue_score = total_rev / 10000000
        
        # Weighted sum & clip
        upsell_score = (volume_score * 0.6) + (revenue_score * 0.4)
        upsell_score = min(max(upsell_score, 0), 1)
        
        new_row['upsell_score'] = upsell_score
        processed.append(new_row)
        
    return processed
