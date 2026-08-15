from fastapi import FastAPI
from pydantic import BaseModel
import re

app = FastAPI(title="JARVIS Backend")


class CommandRequest(BaseModel):
    command: str


class Action(BaseModel):
    type: str
    app: str | None = None
    person: str | None = None
    message: str | None = None


def parse_command(command: str):
    text = command.strip()

    # Example:
    # "open instagram and message BeeshAl hi"
    pattern = re.compile(
        r"(?:open|launch)\s+(?:instagram|insta)"
        r"(?:\s+and\s+(?:message|msg|text|tell)\s+"
        r"(?P<person>[A-Za-z0-9_.-]+)"
        r"(?:\s+(?:saying|that|:)?\s*(?P<message>.+))?)?",
        re.IGNORECASE,
    )

    match = pattern.search(text)

    if match:
        person = match.group("person")
        message = match.group("message")

        if message:
            message = message.strip()

        return [
            Action(
                type="open_app",
                app="instagram",
            ),
            *(
                [
                    Action(
                        type="send_message",
                        app="instagram",
                        person=person,
                        message=message,
                    )
                ]
                if person and message
                else []
            ),
        ]

    if re.search(r"\b(open|launch)\s+(instagram|insta)\b", text, re.I):
        return [
            Action(
                type="open_app",
                app="instagram",
            )
        ]

    return [
        Action(
            type="unknown",
        )
    ]


@app.get("/")
def root():
    return {
        "name": "JARVIS",
        "status": "online",
    }


@app.post("/command")
def command(request: CommandRequest):
    actions = parse_command(request.command)

    return {
        "command": request.command,
        "actions": [action.model_dump() for action in actions],
    }
