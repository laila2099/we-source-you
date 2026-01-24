const admin = require('firebase-admin');

exports.setAdminClaim = async (req, res) => {
  try {
    const idToken = req.headers.authorization?.split('Bearer ')[1];
    if (!idToken) return res.status(401).send({ error: 'Unauthorized' });

    const decoded = await admin.auth().verifyIdToken(idToken);
    if (!decoded.admin) return res.status(403).send({ error: 'Forbidden' });

    const { uid } = req.body;
    if (!uid) return res.status(400).send({ error: 'UID is required' });

    await admin.auth().setCustomUserClaims(uid, { admin: true });
    res.status(200).send({ message: `Admin claim set for UID: ${uid}` });
  } catch (err) {
    console.error(err);
    res.status(500).send({ error: err.message });
  }
};
