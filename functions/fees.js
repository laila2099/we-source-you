function computeFeeRate(paidCount) {
  const n = Number(paidCount ?? 0);
  return n <= 0 ? 0.50 : 0.15;
}

function computeFees(gross, rate) {
  const g = Number(gross);
  const r = Number(rate);

  if (!Number.isFinite(g) || g <= 0) throw new Error('computeFees: invalid gross');
  if (!Number.isFinite(r) || r < 0 || r > 1) throw new Error('computeFees: invalid rate');

  const platformFee = +((g * r).toFixed(2));
  const net = +((g - platformFee).toFixed(2));

  return { platformFee, net };
}


module.exports = { computeFeeRate, computeFees };
