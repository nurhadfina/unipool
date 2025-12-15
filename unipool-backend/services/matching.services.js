const { calculateDistance } = require('../utils/distance.util');
const { calculateTimeDifference } = require('../utils/time.util');

function calculateMatchScore(rideA, rideB) {
    let score = 0;

    const pickupDist = calculateDistance(
        rideA.pickupLocation.latitude,
        rideA.pickupLocation.longitude,
        rideB.pickupLocation.latitude,
        rideB.pickupLocation.longitude
    );

    const dropoffDist = calculateDistance(
        rideA.dropoffLocation.latitude,
        rideA.dropoffLocation.longitude,
        rideB.dropoffLocation.latitude,
        rideB.dropoffLocation.longitude
    );

    if (pickupDist <= 2) score += 20;
    if (dropoffDist <= 2) score += 20;

    const timeDiff = calculateTimeDifference(
        rideA.departureTime,
        rideB.departureTime
    );

    if (timeDiff <= 30) score += 30;

    if (
        rideA.genderPreference === 'any' ||
        rideB.genderPreference === 'any' ||
        rideA.genderPreference === rideB.genderPreference
    ) {
        score += 10;
    }

    return {
        score,
        percentage: Math.round(score)
    };
}

module.exports = { calculateMatchScore };
