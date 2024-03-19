import json




def lambda_handler(event, context):
    return json.dumps({"message": "é nóis garai"})