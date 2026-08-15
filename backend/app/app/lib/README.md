# JARVIS

A personal AI assistant designed to work across Android, iOS,
Windows, macOS and Linux.

## Current MVP

JARVIS can understand commands such as:

- open Instagram
- launch Instagram
- open Instagram and message BeeshAl hi

The backend converts natural-language commands into actions.

## Architecture

Flutter
    |
    v
JARVIS Backend
    |
    v
Command Parser
    |
    v
Action Engine
    |
    +---- Android
    +---- iOS
    +---- Windows
    +---- macOS
    +---- Linux

## Run backend

```bash
cd backend

python -m venv venv

# Windows
venv\Scripts\activate

# Linux/macOS
source venv/bin/activate

pip install -r requirements.txt

uvicorn main:app --reload --host 0.0.0.0 --port 8000
