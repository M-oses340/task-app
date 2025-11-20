import express from "express";
import authRouter from "./routes/auth.js";

const app = express();

// Parse JSON request bodies
app.use(express.json());

app.use("/auth", authRouter);

app.get("/", (req, res) => {
  res.send("Welcome to my app!!!!!!");
});

app.listen(8000, "0.0.0.0", () => {
  console.log("Server started on port 8000");
});

