const express = require('express');
const router = express.Router();
const { db, admin } = require('../firebase');

router.post('/create', async (req, res) => {
    try {
        const { userId, pickupLocation, dropoffLocation, departureTime, maxFare } = req.body;

        if (!userId || !pickupLocation || !dropoffLocation || !departureTime) {
            return res.status(400).json({ error: 'Missing fields' });
        }

        const rideRef = await db.collection('rides').add({
            ...req.body,
            maxFare: maxFare || 0,
            status: 'pending',
            matchedWith: [],
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        res.json({ success: true, rideId: rideRef.id });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
