import { serve } from "bun";
import { Database } from "bun:sqlite";
import dashboard from "./dashboard.html";
import homepage from "./index.html";
import contact from "./contactme.html";

const db = new Database("mydb.sqlite");

const server = serve({
  routes: {
    // ** HTML imports **
    // Bundle & route index.html to "/". This uses HTMLRewriter to scan the HTML for `<script>` and `<link>` tags, run's Bun's JavaScript & CSS bundler on them, transpiles any TypeScript, JSX, and TSX, downlevels CSS with Bun's CSS parser and serves the result.
    "/": homepage,
    // Bundle & route dashboard.html to "/dashboard"
    "/dashboard": dashboard,

    "/contactus": contact,

    // ** API endpoints ** (Bun v1.2.3+ required)
    "/api/users": {
      async GET(req) {
        const users = db.query(`SELECT * FROM users`);
        return Response.json(users);
      },
      async POST(req) {
        // console.log(req);
        const { name, email } = await req.json();;
        db.run("INSERT INTO users (name, email) VALUES (?, ?)", [name, email]);
        // const [user] = db.query("INSERT INTO users (name, email) VALUES ($name, $email)");
        return Response.json({ message: "User created" });
      },
    },
    "/api/users/:id": async req => {
      const { id } = req.params;
      const [user] = db.query(`SELECT * FROM users WHERE id = ${id}`);
      return Response.json(user);
    },
  },

  // Enable development mode for:
  // - Detailed error messages
  // - Hot reloading (Bun v1.2.3+ required)
  development: true,

  // Prior to v1.2.3, the `fetch` option was used to handle all API requests. It is now optional.
  // async fetch(req) {
  //   // Return 404 for unmatched routes
  //   return new Response("Not Found", { status: 404 });
  // },
});

console.log(`Listening on ${server.url}`);