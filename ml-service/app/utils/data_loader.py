"""
Database Connection Utility
Connects to Laravel MySQL database (read-only)
"""
import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    """
    Create and return MySQL database connection
    Uses environment variables for credentials
    """
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            port=int(os.getenv('DB_PORT', 3306)),
            database=os.getenv('DB_NAME', 'bbihub'),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASS', '')
        )
        
        if connection.is_connected():
            print(f"Successfully connected to MySQL database: {os.getenv('DB_NAME')}")
            return connection
    
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        raise
    
    return None


def execute_query(connection, query):
    """
    Execute SQL query and return results as list of dictionaries
    
    Args:
        connection: MySQL connection object
        query: SQL query string
    
    Returns:
        list: Query results as dictionaries
    """
    cursor = connection.cursor(dictionary=True)
    cursor.execute(query)
    results = cursor.fetchall()
    cursor.close()
    return results
