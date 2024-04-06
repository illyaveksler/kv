# kv

**kv** is a simple key-value store written in Prolog.

## To Run

1. Make sure you have Prolog installed.
2. Run `prolog`.
3. Enter the following command to load the key-value store:
   ```prolog
   consult('kv.pl').
   ```

## Example Usage

1. **POST:** Store a key-value pair:
   - Request: `POST` to `http://localhost:8000/put`
   - Body: `{"key":"name", "value":"Alice"}`

2. **GET:** Retrieve the value for a key:
   - Request: `GET` to `http://localhost:8000/get?key=name`

3. **DELETE:** Remove a key-value pair:
   - Request: `DELETE` to `http://localhost:8000/delete?key=name`