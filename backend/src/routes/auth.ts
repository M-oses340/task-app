import { Router, Request, Response } from "express";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import { auth, AuthRequest } from "../middleware/auth.js";
import { NewUser, users } from "../db/schema.js";
import { db } from "../db/index.js";

const authRouter = Router();

interface SignUpBody {
  name: string;
  email: string;
  password: string;
}

interface LoginBody {
  email: string;
  password: string;
}

// -------------------------- SIGNUP --------------------------
authRouter.post(
  "/signup",
  async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    try {
      const { name, email, password } = req.body;

      // Check required fields
      if (!name || !email || !password) {
        return res.status(400).json({ error: "All fields are required" });
      }

      // Check if user exists
      const existingUser = await db
        .select()
        .from(users)
        .where(eq(users.email, email));

      if (existingUser.length) {
        return res
          .status(400)
          .json({ error: "User with the same email already exists!" });
      }

      // Hash password
      const hashedPassword = await bcryptjs.hash(password, 8);

      const newUser: NewUser = {
        name,
        email,
        password: hashedPassword,
      };

      // Insert user
      const [user] = await db.insert(users).values(newUser).returning();

      res.status(201).json(user);
    } catch (e: any) {
      console.error("SIGNUP ERROR:", e);
      res.status(500).json({ error: e.message || e.toString() });
    }
  }
);

// -------------------------- LOGIN --------------------------
authRouter.post(
  "/login",
  async (req: Request<{}, {}, LoginBody>, res: Response) => {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: "Email and password required" });
      }

      const [existingUser] = await db
        .select()
        .from(users)
        .where(eq(users.email, email));

      if (!existingUser) {
        return res
          .status(400)
          .json({ error: "User with this email does not exist!" });
      }

      const isMatch = await bcryptjs.compare(
        password,
        existingUser.password
      );

      if (!isMatch) {
        return res.status(400).json({ error: "Incorrect password!" });
      }

      const token = jwt.sign(
        { id: existingUser.id },
        process.env.JWT_SECRET || "passwordKey"
      );

      res.json({ token, ...existingUser });
    } catch (e: any) {
      console.error("LOGIN ERROR:", e);
      res.status(500).json({ error: e.message || e.toString() });
    }
  }
);

// -------------------------- TOKEN VALIDATION --------------------------
authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);

    const verified = jwt.verify(
      token,
      process.env.JWT_SECRET || "passwordKey"
    );

    if (!verified) return res.json(false);

    const verifiedToken = verified as { id: string };

    const [user] = await db
      .select()
      .from(users)
      .where(eq(users.id, verifiedToken.id));

    if (!user) return res.json(false);

    res.json(true);
  } catch (e: any) {
    console.error("TOKEN VALIDATION ERROR:", e);
    res.status(500).json(false);
  }
});

// -------------------------- GET LOGGED IN USER --------------------------
authRouter.get("/", auth, async (req: AuthRequest, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: "User not found!" });
    }

    const [user] = await db
      .select()
      .from(users)
      .where(eq(users.id, req.user));

    res.json({ ...user, token: req.token });
  } catch (e: any) {
    console.error("GET USER ERROR:", e);
    res.status(500).json({ error: e.message || e.toString() });
  }
});

export default authRouter;
