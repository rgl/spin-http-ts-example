import { HandleRequest, HttpRequest, HttpResponse } from "@fermyon/spin-sdk";

const encoder = new TextEncoder();

function text(status: number, text: string): HttpResponse {
  return {
    status: status,
    headers: {
      "Content-Type": "text/plain",
    },
    body: encoder.encode(text).buffer,
  };
}

function html(status: number, html: string): HttpResponse {
  return {
    status: status,
    headers: {
      "Content-Type": "text/html",
    },
    body: encoder.encode(html).buffer,
  };
}

export const handleRequest: HandleRequest = async (request: HttpRequest): Promise<HttpResponse> => {
  console.log(`client ${request.headers["spin-client-addr"]}: ${request.method} ${request.headers["spin-full-url"]}`);
  const uri = new URL(request.uri);
  if (uri.pathname != "/") {
    return text(404, "Not Found.");
  }
  if (request.method != "GET") {
    return text(405, "Not Allowed.");
  }
  return html(200, `<!DOCTYPE html>
<html>
  <head>
    <title>Hello, World!</title>
  </head>
  <body>
    <p>Hello, World!</p>
  </body>
</html>
`);
};
