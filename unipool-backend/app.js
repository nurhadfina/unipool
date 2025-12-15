const express = require('express');
const cors = require('cors');

const rideRoutes = require('./routes/ride.routes');
const matchRoutes = require('./routes/match.routes');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => res.send('UniPool Backend running'));

app.use('/rides', rideRoutes);
app.use('/matches', matchRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () =>
    console.log(`Server running on http://localhost:${PORT}`)
);
