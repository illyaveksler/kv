# kv

**kv** is a simple key-value store written in Prolog with a tagging system.

## To Run

1. Make sure you have Prolog installed.
2. Run `prolog`.
3. Enter the following command to load the key-value store:
   ```prolog
   consult('kv.pl').
   ```
4. Run another instance of `prolog`.
5. Enter the following on the second instance to start the client:
```prolog
consult('client.pl').
```
## Example Usage

1. **POST:** Store a key-value pair:
   ```prolog
   post_kv([key], [value]).
   ```

2. **GET:** Retrieve the value for a key:
   ```prolog
   get_kv([key], Result).
   ```

3. **DELETE:** Remove a key-value pair:
   ```prolog
   delete_kv([key]).
   ```

4. **TAG:** Add a tag to a key-value pair:
    ```prolog
    tag_kv([key], [tag]).
    ```

5. **UNTAG:** Remove a tag from a tagged key-value pair:
    ```prolog
    untag_kv([key], [tag]).
    ```

6. **TAG_QUERY:** Retrieve a list of keys corresponding to pairs that match the query.
    ```prolog
    tag_query_kv([query], Result).
    ```

    The query can be modified by three operators:
    - **+**: Intersection between two sets
    - **|**: Union between two sets
    - **-**: Subtracting the second set from the first