import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import http from 'http';
import { createApp } from '../src/app.js';

let mongod: MongoMemoryServer | null = null;

async function runTests() {
  console.log('--- Starting Dental Progress Backend Automated Tests ---');

  // Start dedicated In-Memory MongoDB for isolated testing
  mongod = await MongoMemoryServer.create();
  const testUri = mongod.getUri();
  await mongoose.connect(testUri);

  const app = createApp();
  const server = http.createServer(app);

  await new Promise<void>((resolve) => {
    server.listen(0, '127.0.0.1', () => resolve());
  });

  const address = server.address();
  if (!address || typeof address === 'string') {
    throw new Error('Server address error');
  }
  const baseUrl = `http://127.0.0.1:${address.port}`;
  console.log(`Test server running at ${baseUrl}`);

  let token = '';
  let patientId = '';
  let patientMongoId = '';
  let photoId = '';

  try {
    // 1. Health check
    console.log('[TEST 1] GET /api/health');
    const healthRes = await fetch(`${baseUrl}/api/health`);
    const healthJson = await healthRes.json();
    if (healthRes.status !== 200 || !healthJson.success) {
      throw new Error(`Health check failed: ${JSON.stringify(healthJson)}`);
    }
    console.log('✓ Health check passed');

    // 2. Auth: Register
    console.log('[TEST 2] POST /api/auth/register');
    const regRes = await fetch(`${baseUrl}/api/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Dr. John Miller, Orthodontist',
        email: 'dr.john@example.com',
        password: 'password123',
      }),
    });
    const regJson = await regRes.json();
    if (regRes.status !== 201 || !regJson.data?.token) {
      throw new Error(`Register failed: ${JSON.stringify(regJson)}`);
    }
    token = regJson.data.token;
    console.log('✓ Register dentist passed, token received');

    // 3. Auth: Login
    console.log('[TEST 3] POST /api/auth/login');
    const loginRes = await fetch(`${baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'dr.john@example.com',
        password: 'password123',
      }),
    });
    const loginJson = await loginRes.json();
    if (loginRes.status !== 200 || !loginJson.data?.token) {
      throw new Error(`Login failed: ${JSON.stringify(loginJson)}`);
    }
    console.log('✓ Login dentist passed');

    // 4. Auth: Get Me
    console.log('[TEST 4] GET /api/auth/me');
    const meRes = await fetch(`${baseUrl}/api/auth/me`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const meJson = await meRes.json();
    if (meRes.status !== 200 || meJson.data?.email !== 'dr.john@example.com') {
      throw new Error(`GetMe failed: ${JSON.stringify(meJson)}`);
    }
    console.log('✓ Get Me passed:', meJson.data.name);

    // 5. Patient: Create Patient (US-01)
    console.log('[TEST 5] POST /api/patients');
    const createPatientRes = await fetch(`${baseUrl}/api/patients`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        name: 'Alexander Chen',
        dateOfBirth: '1998-05-14',
        gender: 'Male',
        phone: '+1 555-019-2834',
        additionalInformation: 'Class II Division 1 Malocclusion, deep bite.',
      }),
    });
    const createPatientJson = await createPatientRes.json();
    if (createPatientRes.status !== 201 || !createPatientJson.data?.patientId) {
      throw new Error(`Create patient failed: ${JSON.stringify(createPatientJson)}`);
    }
    patientId = createPatientJson.data.patientId;
    patientMongoId = createPatientJson.data._id;
    console.log(`✓ Patient created with auto-generated ID: ${patientId}`);

    // 6. Patient: Validation check (US-01)
    console.log('[TEST 6] POST /api/patients (Validation failure check)');
    const invalidPatientRes = await fetch(`${baseUrl}/api/patients`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        name: '', // Empty name should fail
        dateOfBirth: 'invalid-date',
        gender: 'Unknown',
        phone: '',
      }),
    });
    if (invalidPatientRes.status !== 400) {
      throw new Error(`Expected 400 validation error, got: ${invalidPatientRes.status}`);
    }
    console.log('✓ Patient validation correctly rejected invalid inputs');

    // 7. Patient: Search & List (US-06)
    console.log('[TEST 7] GET /api/patients?search=Alexander');
    const searchRes = await fetch(`${baseUrl}/api/patients?search=Alexander`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const searchJson = await searchRes.json();
    if (searchRes.status !== 200 || searchJson.data.length !== 1) {
      throw new Error(`Search failed: ${JSON.stringify(searchJson)}`);
    }
    console.log(`✓ Search patient passed, found: ${searchJson.data[0].name}`);

    // 8. Patient: Edit Patient (US-02)
    console.log('[TEST 8] PATCH /api/patients/:id');
    const editRes = await fetch(`${baseUrl}/api/patients/${patientId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        phone: '+1 555-999-8888',
        additionalInformation: 'Updated note: Progressing with aligner #4',
      }),
    });
    const editJson = await editRes.json();
    if (editRes.status !== 200 || editJson.data.phone !== '+1 555-999-8888') {
      throw new Error(`Edit patient failed: ${JSON.stringify(editJson)}`);
    }
    console.log('✓ Edit patient passed');

    // 9. Photo: Upload Photo (US-03)
    console.log('[TEST 9] POST /api/patients/:patientId/photos');
    // Create a 1x1 transparent PNG buffer
    const pngBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
    const imageBuffer = Buffer.from(pngBase64, 'base64');

    const boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
    let body = '';
    body += `--${boundary}\r\n`;
    body += `Content-Disposition: form-data; name="category"\r\n\r\nFrontal Smile\r\n`;
    body += `--${boundary}\r\n`;
    body += `Content-Disposition: form-data; name="documentationDate"\r\n\r\n2026-09-01T10:00:00.000Z\r\n`;
    body += `--${boundary}\r\n`;
    body += `Content-Disposition: form-data; name="notes"\r\n\r\nInitial visit baseline frontal smile photo.\r\n`;
    body += `--${boundary}\r\n`;
    body += `Content-Disposition: form-data; name="photo"; filename="smile_baseline.png"\r\n`;
    body += `Content-Type: image/png\r\n\r\n`;

    const bodyHead = Buffer.from(body, 'utf-8');
    const bodyTail = Buffer.from(`\r\n--${boundary}--\r\n`, 'utf-8');
    const multipartBody = Buffer.concat([bodyHead, imageBuffer, bodyTail]);

    const uploadRes = await fetch(`${baseUrl}/api/patients/${patientId}/photos`, {
      method: 'POST',
      headers: {
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        Authorization: `Bearer ${token}`,
      },
      body: multipartBody,
    });
    const uploadJson = await uploadRes.json();
    if (uploadRes.status !== 201 || !uploadJson.data?.imageUrl) {
      throw new Error(`Photo upload failed: ${JSON.stringify(uploadJson)}`);
    }
    photoId = uploadJson.data._id;
    console.log(`✓ Photo uploaded successfully, photo ID: ${photoId}, URL: ${uploadJson.data.imageUrl}`);

    // 10. Photo: Group Photos by Patient (US-04)
    console.log('[TEST 10] GET /api/patients/:patientId/photos');
    const listPhotosRes = await fetch(`${baseUrl}/api/patients/${patientId}/photos`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const listPhotosJson = await listPhotosRes.json();
    if (listPhotosRes.status !== 200 || listPhotosJson.data.photos.length !== 1) {
      throw new Error(`Get photos failed: ${JSON.stringify(listPhotosJson)}`);
    }
    console.log(`✓ Group photos by patient passed: ${listPhotosJson.data.photos.length} photo found`);

    // 11. Photo: Edit Photo Notes (US-05 & US-08)
    console.log('[TEST 11] PATCH /api/photos/:id');
    const updatePhotoRes = await fetch(`${baseUrl}/api/photos/${photoId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        notes: 'Updated note: Upper central incisor alignment improving nicely.',
        category: 'Upper Occlusal',
      }),
    });
    const updatePhotoJson = await updatePhotoRes.json();
    if (updatePhotoRes.status !== 200 || !updatePhotoJson.data.notes.includes('alignment improving')) {
      throw new Error(`Update photo note failed: ${JSON.stringify(updatePhotoJson)}`);
    }
    console.log('✓ Edit photo notes passed');

    // 12. Dashboard: Stats (Feature 2)
    console.log('[TEST 12] GET /api/dashboard/stats');
    const statsRes = await fetch(`${baseUrl}/api/dashboard/stats`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const statsJson = await statsRes.json();
    if (statsRes.status !== 200 || statsJson.data.totalPatients !== 1 || statsJson.data.totalPhotos !== 1) {
      throw new Error(`Dashboard stats failed: ${JSON.stringify(statsJson)}`);
    }
    console.log('✓ Dashboard stats passed:', statsJson.data);

    // 13. Photo: Delete Photo (US-05)
    console.log('[TEST 13] DELETE /api/photos/:id');
    const delPhotoRes = await fetch(`${baseUrl}/api/photos/${photoId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` },
    });
    const delPhotoJson = await delPhotoRes.json();
    if (delPhotoRes.status !== 200) {
      throw new Error(`Delete photo failed: ${JSON.stringify(delPhotoJson)}`);
    }
    console.log('✓ Delete photo passed');

    // 14. Patient: Delete Patient (US-02)
    console.log('[TEST 14] DELETE /api/patients/:id');
    const delPatientRes = await fetch(`${baseUrl}/api/patients/${patientId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` },
    });
    const delPatientJson = await delPatientRes.json();
    if (delPatientRes.status !== 200) {
      throw new Error(`Delete patient failed: ${JSON.stringify(delPatientJson)}`);
    }
    console.log('✓ Delete patient passed');

    console.log('\n======================================================');
    console.log(' ALL BACKEND AUTOMATED TESTS PASSED SUCCESSFULLY! ');
    console.log('======================================================\n');
  } finally {
    server.close();
    await mongoose.disconnect();
    if (mongod) {
      await mongod.stop();
    }
  }
}

runTests().catch((err) => {
  console.error('Test suite failed:', err);
  process.exit(1);
});
