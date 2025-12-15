function calculateTimeDifference(time1, time2) {
    const t1 = time1.toMillis ? time1.toMillis() : new Date(time1).getTime();
    const t2 = time2.toMillis ? time2.toMillis() : new Date(time2).getTime();
    return Math.abs(t1 - t2) / 60000;
}

module.exports = { calculateTimeDifference };
