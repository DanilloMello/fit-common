import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import * as fs from "fs/promises";
import * as path from "path";

const DOCS = process.env.DOCS_PATH || "..";

const server = new Server(
  { name: "fit-common", version: "2.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "load_skill",
      description: "Load a skill. Start with 'project-orchestrator-doc' to route.",
      inputSchema: {
        type: "object",
        properties: {
          skill: { type: "string", enum: ["project-orchestrator-doc", "fit-api", "fit-mobile"] }
        },
        required: ["skill"],
      },
    },
    {
      name: "read_common",
      description: "Read shared docs (DOMAIN_SPEC, API_REGISTRY, PRD, SPRINT_PLAN)",
      inputSchema: {
        type: "object",
        properties: {
          file: { type: "string", enum: ["DOMAIN_SPEC", "API_REGISTRY", "PRD", "SPRINT_PLAN"] }
        },
        required: ["file"],
      },
    },
    {
      name: "read_app_doc",
      description: "Read app-specific doc",
      inputSchema: {
        type: "object",
        properties: {
          app: { type: "string", enum: ["fit-api", "fit-mobile"] },
          file: { type: "string", enum: ["ARCHITECTURE", "DATABASE", "SCREENS"] }
        },
        required: ["app", "file"],
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (req) => {
  const { name, arguments: args } = req.params;
  try {
    let content = "";
    switch (name) {
      case "load_skill":
        content = await fs.readFile(path.join(DOCS, "skills", args.skill, "SKILL.md"), "utf-8");
        break;
      case "read_common":
        content = await fs.readFile(path.join(DOCS, "docs", `${args.file}.md`), "utf-8");
        break;
      case "read_app_doc":
        content = await fs.readFile(path.join(DOCS, args.app, `${args.file}.md`), "utf-8");
        break;
    }
    return { content: [{ type: "text", text: content }] };
  } catch (e) {
    return { content: [{ type: "text", text: `Error: ${e}` }] };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}
main().catch(console.error);
