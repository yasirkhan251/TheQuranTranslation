import { spawn } from "node:child_process";
import process from "node:process";

const isWindows = process.platform === "win32";
const pythonCommand = isWindows ? "py" : "python3";
const npmCommand = isWindows ? "npm.cmd" : "npm";
const children = [];

function start(label, command, args) {
  console.log("\n[Noor] Starting " + label + "...");
  const child = spawn(command, args, {
    cwd: process.cwd(),
    stdio: "inherit",
    shell: isWindows,
  });
  children.push(child);
  child.on("error", (error) => {
    console.error("[Noor] Could not start " + label + ":", error.message);
  });
  child.on("exit", (code, signal) => {
    if (code && code !== 0) {
      console.error("[Noor] " + label + " exited with code " + code + (signal ? " (signal " + signal + ")" : "") + ".");
    }
  });
  return child;
}

const tts = start("Urdu/English neural TTS server", pythonCommand, [
  "-c",
  "import runpy; runpy.run_path('tts_server.py', run_name='__main__')",
]);
const vite = start("Vite development server", npmCommand, ["run", "dev"]);

console.log("\n[Noor] Both services have been requested.");
console.log("[Noor] Keep this window open; press Ctrl+C to stop both.");
console.log("[Noor] If TTS fails to start, install dependencies with: py -m pip install -r requirements-tts.txt");

function stopAll() {
  for (const child of children) {
    if (!child.killed) child.kill();
  }
}
process.on("SIGINT", () => {
  stopAll();
  process.exit(0);
});
process.on("SIGTERM", stopAll);
