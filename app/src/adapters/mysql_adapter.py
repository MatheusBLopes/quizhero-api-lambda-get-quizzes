import mysql.connector


class MySqlAdapater:
    def __init__(self, host, user, password, database):
        self.host = host
        self.user = user
        self.password = password
        self.database = database

    def connect_to_database(self):
        try:
            # Establish connection to MySQL database
            connection = mysql.connector.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                database=self.database,
                port=3306
            )
            
            if connection.is_connected():
                print("Connected to MySQL database")
                return connection

        except Exception as e:
            raise e

    def close_connection(self, connection):
        if connection:
            connection.close()
            print("Connection to MySQL database closed")