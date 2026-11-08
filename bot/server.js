import express from "express";

const app = express();
app.use(express.json({ limit: "1mb" }));

const PORT = process.env.PORT || 3000;
const VERIFY_TOKEN = process.env.WHATSAPP_VERIFY_TOKEN;
const ACCESS_TOKEN = process.env.WHATSAPP_ACCESS_TOKEN;
const PHONE_NUMBER_ID = process.env.WHATSAPP_PHONE_NUMBER_ID;

app.get("/", (_req, res) => {
  res.status(200).send("H.M STORE AI server is running.");
});

// Meta webhook verification
app.get("/webhook", (req, res) => {
  const mode = req.query["hub.mode"];
  const token = req.query["hub.verify_token"];
  const challenge = req.query["hub.challenge"];

  if (mode === "subscribe" && VERIFY_TOKEN && token === VERIFY_TOKEN) {
    return res.status(200).send(challenge);
  }
  return res.sendStatus(403);
});

// Receive WhatsApp messages. The AI reply flow will be added after Cloud API setup.
app.post("/webhook", async (req, res) => {
  // Acknowledge quickly so Meta does not repeatedly retry the webhook.
  res.sendStatus(200);

  try {
    const entries = req.body?.entry ?? [];
    for (const entry of entries) {
      for (const change of entry.changes ?? []) {
        const value = change.value ?? {};
        for (const message of value.messages ?? []) {
          console.log("Incoming WhatsApp message", {
            from: message.from,
            type: message.type,
            timestamp: message.timestamp
          });

          // Deliberately do not send an automatic reply yet.
          // The customer-support AI and approved reply rules will be connected next.
        }
      }
    }
  } catch (error) {
    console.error("Webhook processing error:", error);
  }
});

app.listen(PORT, () => {
  console.log(`H.M STORE AI listening on port ${PORT}`);
});
