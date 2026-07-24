# Deploy VyralIQ Cloud Functions

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Set the OpenAI secret: `firebase functions:secrets:set OPENAI_API_KEY`
   (paste your key when prompted)
4. Deploy: `firebase deploy --only functions`
5. The function URL will be printed — the Flutter app will auto-detect it

## Project

- Firebase project ID: `vyraliq`
- Function name: `generateContent`
- Runtime: Node.js 20
