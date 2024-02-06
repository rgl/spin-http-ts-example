import { HandleRequest, HttpRequest, HttpResponse } from "@fermyon/spin-sdk";
import { sourceUrl, version, revision, authorName, authorUrl } from "./meta";

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
  if (request.method != "GET" && request.method != "HEAD") {
    return text(405, "Not Allowed.");
  }
  return html(200, `<!DOCTYPE html>
<html>
  <head>
    <title>Hello, World!</title>
    <link rel="icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAsklEQVR4nNXRSwrCQAwG4NFLeB9voIiINNl4BZPBVUUXVtyI4KbJrLyIl3Ljg4otFSlOcWbnvw1fkskY858pTAfFJmmadiMxH1G5AKVTDD5UmK/o5oMgD0rbaIxKGy9OcttvnSy0qzEIDxtF3pdFoeV3zJkXl9Mdz0DpUTXhrIHXP70ZxE5R6fbZBJVWQQcDJUDh+wuh8Ll1bV/Q8fi9ScxXlU1yHoHSJQrXmciiF41D8wTn54OWVxRsfQAAAABJRU5ErkJggg==" />
    <style>
      body {
        margin: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
        text-align: center;
        font-size: 27px;
      }
      .version {
        color: #aaa;
        font-style: italic;
        font-size: 0.6em;
      }
      .version a {
        color: inherit;
        text-decoration: none;
      }
      .version a:hover {
        text-decoration: underline;
      }
    </style>
  </head>
  <body>
    <div>
      <p>Hello, World!</p>
      <p class="version">v${version}+${revision}<br/><a href="${sourceUrl}">${sourceUrl}</a><br>by <a href="${authorUrl}">${authorName}</a></p>
    </div>
  </body>
</html>
`);
};
