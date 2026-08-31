import json
import os
import uuid
from datetime import datetime, timezone

import boto3

table = boto3.resource("dynamodb").Table(os.environ["NOTES_TABLE"])

def response(status, body=None):
    return {"statusCode": status, "headers": {"content-type": "application/json"}, "body": json.dumps(body or {})}

def handler(event, context):
    method = event["requestContext"]["http"]["method"]
    note_id = event.get("pathParameters", {}).get("id")
    if method == "GET" and not note_id:
        return response(200, table.scan().get("Items", []))
    if method == "GET":
        item = table.get_item(Key={"id": note_id}).get("Item")
        return response(200, item) if item else response(404, {"message": "Note not found"})
    if method == "POST":
        payload = json.loads(event.get("body") or "{}")
        if not payload.get("content"):
            return response(400, {"message": "content is required"})
        item = {"id": str(uuid.uuid4()), "content": payload["content"], "created_at": datetime.now(timezone.utc).isoformat()}
        table.put_item(Item=item)
        return response(201, item)
    if method == "DELETE":
        table.delete_item(Key={"id": note_id})
        return response(204)
    return response(405, {"message": "Method not allowed"})
