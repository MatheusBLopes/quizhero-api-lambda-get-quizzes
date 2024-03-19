import json
from src.adapters.mysql_adapter import MySqlAdapater

def lambda_handler(event, context):
    host = 'quizhero.cb0yj0kskzwr.us-east-1.rds.amazonaws.com'
    user = 'lifemanager'
    password = 'dbpassword'
    database = 'quizhero'

    try:
        # Connect to the MySQL database
        db_adapter = MySqlAdapater(host, user, password, database)
        connection = db_adapter.connect_to_database()

        db_adapter.close_connection(connection)
        return json.dumps({"message": "é nóis garai"})
    except Exception as e:
        raise e