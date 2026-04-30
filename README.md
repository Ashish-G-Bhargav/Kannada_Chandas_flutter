# Kannada Chandas Flutter

Flutter port of the Kannada Chandas Identifier UI.

## Features

- Analyze Kannada poetry through Flask endpoint `/analyze`
- OCR image upload through `/ocr`
- Save analyzed result through `/save`
- Browse and reload saved verses from `/history`

## Run

1. Start backend from the parent project folder:

```bash
python app.py
```

2. Run Flutter app:

```bash
flutter pub get
flutter run
```

## Backend URL

Default URL is `http://127.0.0.1:5000`.

Use the app bar network settings icon to update it as needed.
For Android emulator, use `http://10.0.2.2:5000`.

## Windows Note

If dependency install reports symlink issues, enable Windows Developer Mode:

```powershell
start ms-settings:developers
```
