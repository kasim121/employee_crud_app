const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();

// Simulated Email Notification Function
exports.sendEmailNotification = onRequest(async (req, res) => {
    const { email, subject, message } = req.body;

    // Save notification to Firestore (optional for logging/demo purposes)
    await admin.firestore().collection("notifications").add({
        email: email,
        subject: subject,
        message: message,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Simulate sending an email
    console.log(`Simulated email sent to: ${email}`);
    console.log(`Subject: ${subject}`);
    console.log(`Message: ${message}`);

    res.status(200).send(`Simulated email sent to: ${email}`);
});
