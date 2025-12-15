const express = require('express');
const router = express.Router();
const { db, admin } = require('../firebase');
const { calculateMatchScore } = require('../services/matching.service');

router.get('/:userId', async (req, res) => {
    try {
        const { userId } = req.params;

        const userRideSnap = await db
            .collection('rides')
            .where('userId', '==', userId)
            .where('status', '==', 'pending')
            .limit(1)
            .get();

        if (userRideSnap.empty) {
            return res.json({ matches: [] });
        }

        const userRide = { id: userRideSnap.docs[0].id, ...userRideSnap.docs[0].data() };

        const allRidesSnap = await db
            .collection('rides')
            .where('status', '==', 'pending')
            .get();

        const matches = [];

        allRidesSnap.forEach(doc => {
            if (doc.id === userRide.id) return;
            const otherRide = { id: doc.id, ...doc.data() };

            const match = calculateMatchScore(userRide, otherRide);
            if (match.percentage >= 50) {
                matches.push({ rideId: doc.id, match });
            }
        });

        res.json({ matches });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
