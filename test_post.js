const dns = require('node:dns');
dns.setDefaultResultOrder('ipv4first');

const test_body = JSON.stringify({
    key: "a",
    tag: "tag1"
  });
  
const url = new URL("http://localhost:8000/tag");

fetch(url, {
  method: "POST",
  body: test_body,
  headers: {
    "Content-type": "application/json; charset=UTF-8"
  }
});
