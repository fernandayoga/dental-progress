/**
 * Generates an auto-incremented or cleanly formatted Patient ID like DP-2026-0042
 */
export const generatePatientId = (seqNumber?: number): string => {
  const currentYear = new Date().getFullYear();
  if (seqNumber !== undefined && seqNumber !== null) {
    const padded = String(seqNumber).padStart(4, '0');
    return `DP-${currentYear}-${padded}`;
  }
  // Fallback random 4-digit format if sequence not passed
  const randomSuffix = Math.floor(1000 + Math.random() * 9000);
  return `DP-${currentYear}-${randomSuffix}`;
};
