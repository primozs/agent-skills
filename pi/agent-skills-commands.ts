// agent-skills — pi extension that registers /as-* commands
// Mirrors the Claude Code commands/*.toml and Cursor command-skills/as-*
//
// Global install: symlink to ~/.pi/agent/extensions/agent-skills-commands.ts
// Per-repo: symlink to .pi/extensions/agent-skills-commands.ts

import { readFileSync, realpathSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Resolve the commands dir relative to this file (works through symlink)
function findCommandsDir(): string {
  // __dirname is the symlink location (~/.pi/agent/extensions/) — a real dir.
  // We need to resolve the FILE symlink to find the repo's commands/ dir.
  const thisFile =
    typeof __filename === "undefined"
      ? fileURLToPath(import.meta.url)
      : __filename;
  const realFile = realpathSync(thisFile);
  const realDir = dirname(realFile);
  const candidates = [
    resolve(realDir, "..", "commands"),
    resolve(realDir, "..", "..", "commands"),
  ];
  for (const dir of candidates) {
    try {
      readFileSync(resolve(dir, "spec.toml"), "utf8");
      return dir;
    } catch {
      /* try next */
    }
  }
  // Fallback: walk up from this file
  let dir = realDir;
  for (let i = 0; i < 5; i++) {
    const candidate = resolve(dir, "commands");
    try {
      readFileSync(resolve(candidate, "spec.toml"), "utf8");
      return candidate;
    } catch {
      dir = resolve(dir, "..");
    }
  }
  throw new Error("agent-skills-commands: could not find commands/ directory");
}

function parseToml(content: string): { description: string; prompt: string } {
  const descMatch = content.match(/^description\s*=\s*"([^"]*)"/m);
  const promptMatch = content.match(/^prompt\s*=\s*"""([\s\S]*?)"""/m);
  return {
    description: descMatch?.[1] ?? "",
    prompt: promptMatch?.[1]?.trim() ?? "",
  };
}

function loadCommand(name: string, dir: string) {
  const content = readFileSync(resolve(dir, `${name}.toml`), "utf8");
  return parseToml(content);
}

export default function (pi: ExtensionAPI) {
  const commandsDir = findCommandsDir();

  const commands: [string, string][] = [
    ["as-spec", "spec"],
    ["as-plan", "planning"],
    ["as-build", "build"],
    ["as-test", "test"],
    ["as-review", "review"],
    ["as-code-simplify", "code-simplify"],
    ["as-ship", "ship"],
    ["as-webperf", "webperf"],
  ];

  for (const [cmdName, tomlFile] of commands) {
    const { description, prompt } = loadCommand(tomlFile, commandsDir);

    pi.registerCommand(cmdName, {
      description,
      handler: async (args: string) => {
        const message = args
          ? `${prompt}\n\n## User arguments\n\n${args}`
          : prompt;
        pi.sendUserMessage(message);
      },
    });
  }
}
