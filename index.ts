import { serve } from "bun";
import { Database } from "bun:sqlite";
import { betterAuth } from "better-auth";

import dashboard from "./dashboard.html";
import homepage from "./index.html";
import contact from "./contactme.html";
import helpDeskDashboard from "./helpdesk_dashboard.html";
import agentDashboard from "./agent_dashboard.html";
import adminDashboard from "./admin_dashboard.html";

import qmsDashboard from "./qms_dashboard.html";
import qmsDocument from "./qms_document.html";
import qmsTraining from "./qms_training.html";
import qmsEvents from "./qms_events.html";
import qmsReports from "./qms_reports.html";
import qmsAdmin from "./qms_admin.html";

import simplePing from "./simpleping.html";

const db = new Database("mydb.sqlite");

// export const auth = betterAuth({
//   // The secret used to sign the JWT
//   database: new Database("mydb.sqlite"),
//   emailAndPassword: {
//     // The secret used to sign the JWT
//     enabled: true,
//   },
// });

const server = serve({
  routes: {
    // ** HTML imports **
    // Bundle & route index.html to "/". This uses HTMLRewriter to scan the HTML for `<script>` and `<link>` tags, run's Bun's JavaScript & CSS bundler on them, transpiles any TypeScript, JSX, and TSX, downlevels CSS with Bun's CSS parser and serves the result.
    "/": homepage,
    // Bundle & route dashboard.html to "/dashboard"
    "/dashboard": dashboard,

    "/contactus": contact,
    // IT Help Desk
    "/it": helpDeskDashboard,
    "/it_agent": agentDashboard,
    "/it_admin": adminDashboard,

    // Quality Management System
    "/qms": qmsDashboard,
    "/qms_document": qmsDocument,
    "/qms_training": qmsTraining,
    "/qms_events": qmsEvents,
    "/qms_reports": qmsReports,
    "/qms_admin": qmsAdmin,

    // Simple Ping

    "/ping": simplePing,

    // "/api/auth/*": auth.handler,

    "/api/contact": {
      async POST(req) {
        // console.log(req);
        const { name, email, request } = await req.json();;
        db.run("INSERT INTO contact_requests (full_name, email_address, request_message) VALUES (?, ?, ?)", [name, email, request]);
        // const [user] = db.query("INSERT INTO users (name, email) VALUES ($name, $email)");
        return new Response(JSON.stringify({ message: "contact created" }), {
          headers: { "Content-Type": "application/json" },
        });
      },
    },
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
        return new Response(JSON.stringify({ message: "User created" }), {
          headers: { "Content-Type": "application/json" },
        });
      },
    },
    "/api/users/:id": async req => {
      const { id } = req.params;
      const [user] = db.query(`SELECT * FROM users WHERE id = ${id}`);
      return Response.json(user);
    },

    // Simple Ping APIs
    "/api/simpleping": {
      async GET(req) {
        return Response.json({ message: "User created" });
      },
      async POST(req) {
        const { email, url } = await req.json();;
        return Response.json({ message: "User created" });
        // const { url } = await req.json();
        // const response = await fetch(url);
        // return Response.json({ status: response.status });
      },
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