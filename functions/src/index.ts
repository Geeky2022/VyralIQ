import * as functions from "firebase-functions/v2/https";
import OpenAI from "openai";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface ContentRequest {
  platform: string;
  niche: string;
  goal: string;
  tone: string;
  length: string;
  /** If set, uses daily variant prompts for weekly calendar generation. */
  dayOfWeek?: string;
}

interface Script {
  hook: string;
  body: string;
  cta: string;
}

interface GenerationResult {
  viralHooks: string[];
  videoIdeas: string[];
  scripts: Script[];
  caption: string;
  cta: string;
  hashtags: string[];
  thumbnailText: string;
  editingSuggestions: string;
  bRollIdeas: string[];
  cameraAngles: string;
  lightingSuggestions: string;
  musicStyle: string;
  bestPostingTime: string;
  seoKeywords: string[];
  repurposeIdeas: string[];
  carouselVersion: string;
  instagramStoryVersion: string;
  facebookVersion: string;
  linkedinVersion: string;
  pinterestVersion: string;
  platform: string;
  niche: string;
  goal: string;
  tone: string;
  length: string;
}

// ---------------------------------------------------------------------------
// Prompt Templates (ported from lib/services/prompt_templates.dart)
// ---------------------------------------------------------------------------

function systemPrompt(platform: string, tone: string, niche: string): string {
  return `You are an expert Creative Director and social media strategist at VyralIQ, a premium AI content studio. You create content for ${platform}. Your tone is ${tone}. Your writing is strategic, engaging, and tailored for the ${niche} niche. You never produce generic content — every output feels handcrafted by a professional agency. You think like a storyteller, strategist, and brand builder. Your responses should feel like they came from a top-tier creative agency, not a chatbot. Be specific, actionable, and original. Avoid clichés and filler.`;
}

function viralHooksPrompt(req: ContentRequest): string {
  return `Generate exactly 25 scroll-stopping viral hooks for ${req.platform} in the ${req.niche} niche.
Goal: ${req.goal}. Tone: ${req.tone}. Content length style: ${req.length}.

Requirements:
- Each hook must be a single compelling sentence
- Vary the hook styles: curiosity gaps, bold statements, controversial takes, questions, pattern interrupts, listicles, "how to" hooks
- Make them platform-native (e.g. fast cuts for TikTok, professional polish for LinkedIn)
- Number them 1–25
- Return ONLY the numbered list, no preamble.`;
}

function videoIdeasPrompt(req: ContentRequest): string {
  return `Generate exactly 10 unique video content ideas for ${req.platform} in the ${req.niche} niche.
Goal: ${req.goal}. Tone: ${req.tone}. Content length style: ${req.length}.

Requirements:
- Each idea should include a strong concept/title and a 1–2 sentence description
- Make them original — nothing generic like "day in the life"
- Tailor to ${req.platform}'s format (vertical short-form, horizontal long-form, etc.)
- Number them 1–10
- Return ONLY the numbered list.`;
}

function scriptsPrompt(req: ContentRequest): string {
  return `Generate exactly 5 complete video scripts for ${req.platform} in the ${req.niche} niche.
Goal: ${req.goal}. Tone: ${req.tone}. Content length style: ${req.length}.

For each script, provide exactly 3 sections labeled HOOK, BODY, and CTA.

Requirements:
- HOOK: 1–2 gripping opening lines designed to stop the scroll immediately
- BODY: The main content — substantive, well-structured, value-packed. Adapt length to "${req.length}" style.
- CTA: A strategic call-to-action that drives engagement (not just "like and subscribe")

Format each script as:
SCRIPT 1
HOOK: ...
BODY: ...
CTA: ...

SCRIPT 2
HOOK: ...
BODY: ...
CTA: ...

(Continue for all 5 scripts)`;
}

function captionPrompt(req: ContentRequest): string {
  return `Write one expertly crafted social media caption for ${req.platform} in the ${req.niche} niche.
Goal: ${req.goal}. Tone: ${req.tone}. Content length style: ${req.length}.

Requirements:
- Lead with a powerful hook line
- Break text into scannable paragraphs (short lines, whitespace between)
- Include emotional triggers and strategic framing
- End with a clear CTA
- Include 15–20 relevant, high-performing hashtags at the end
- Write the caption naturally — no brackets, no placeholders

Format:
CAPTION:
[the caption text]

HASHTAGS:
[hashtags listed space-separated]`;
}

function visualPrompt(req: ContentRequest): string {
  return `You are a visual creative director. Provide production guidance for a ${req.platform} video in the ${req.niche} niche with a ${req.tone} tone.

Provide exactly the following sections:

THUMBNAIL TEXT:
[A bold, clickable text overlay suggestion — max 6 words]

EDITING SUGGESTIONS:
[A paragraph on pacing, transitions, text overlays, and timing]

B-ROLL IDEAS:
[A list of 5 specific b-roll shot suggestions]

CAMERA ANGLES:
[2–3 recommended angles with reasoning]

LIGHTING SUGGESTIONS:
[A paragraph on mood lighting and setup]

MUSIC STYLE:
[A specific music genre or vibe recommendation]`;
}

function strategyPrompt(req: ContentRequest): string {
  return `You are a social media strategist. Provide optimization guidance for ${req.platform} in the ${req.niche} niche with the goal of ${req.goal}.

Provide exactly:

BEST POSTING TIME:
[One recommended time/day with brief reasoning]

SEO KEYWORDS:
[A comma-separated list of 10 relevant high-volume keywords]

REPURPOSE IDEAS:
[A list of 5 specific ways to repurpose this content across other platforms]`;
}

function crossPlatformPrompt(req: ContentRequest): string {
  return `You are a cross-platform content strategist. Take the core content idea for the ${req.niche} niche (goal: ${req.goal}, tone: ${req.tone}, length: ${req.length}) and adapt it for:

CAROUSEL VERSION:
[A slide-by-slide breakdown for an Instagram/LinkedIn carousel post — 5–7 slides]

INSTAGRAM STORY VERSION:
[A sequence of 3–5 story frames with text and visual direction]

FACEBOOK VERSION:
[A longer-form version optimized for Facebook engagement]

LINKEDIN VERSION:
[A professional rewrite optimized for LinkedIn's feed]

PINTEREST VERSION:
[A Pinterest-optimized description with SEO keywords]

Be specific — give actionable copy, not vague suggestions.`;
}

// ---------------------------------------------------------------------------
// Daily Variant Prompts (for weekly calendar)
// ---------------------------------------------------------------------------

function dailyVariantSystemPrompt(
  platform: string,
  tone: string,
  niche: string,
  dayOfWeek: string
): string {
  return `You are an expert Creative Director and social media strategist at VyralIQ, a premium AI content studio. You create content for ${platform}. Your tone is ${tone}. Your writing is strategic, engaging, and tailored for the ${niche} niche. Today is ${dayOfWeek}. Weave the energy and vibe of ${dayOfWeek} naturally into the content — but don't make it the focal point. Never generic. Every output feels handcrafted by a professional agency.`;
}

function dailyViralHooksPrompt(req: ContentRequest): string {
  return `Generate exactly 3 compelling viral hooks for a ${req.dayOfWeek} post on ${req.platform} in the ${req.niche} niche.
Goal: ${req.goal}. Tone: ${req.tone}.

Let the ${req.dayOfWeek} energy subtly influence the hooks. Number them 1–3. Return ONLY the numbered list.`;
}

function dailyScriptIdeaPrompt(req: ContentRequest): string {
  return `Generate one complete script idea for a ${req.dayOfWeek} post on ${req.platform} in the ${req.niche} niche.
Goal: ${req.goal}. Tone: ${req.tone}.

Provide:
HOOK: ...
BODY: ...
CTA: ...

Let the ${req.dayOfWeek} energy subtly influence the tone. Return ONLY the formatted script.`;
}

function dailyCaptionPrompt(req: ContentRequest): string {
  return `Write a caption for a ${req.dayOfWeek} post on ${req.platform} in the ${req.niche} niche.
Goal: ${req.goal}. Tone: ${req.tone}.

Provide:
CAPTION:
[the caption]

HASHTAGS:
[8-10 relevant hashtags]

Let ${req.dayOfWeek} energy subtly influence the copy.`;
}

// ---------------------------------------------------------------------------
// Parsers (ported from lib/services/generation_service.dart)
// ---------------------------------------------------------------------------

function parseNumberedList(raw: string): string[] {
  const lines = raw.split("\n");
  const items: string[] = [];
  const regex = /^\s*\d+[\.\)\-\:]\s*(.+)/;
  for (const line of lines) {
    const match = regex.exec(line);
    if (match && match[1]) {
      const text = match[1].trim();
      if (text) items.push(text);
    }
  }
  return items;
}

function parseScripts(raw: string): Script[] {
  const scripts: Script[] = [];
  const parts = raw.split(/SCRIPT\s*\d+/i);
  for (const part of parts) {
    const trimmed = part.trim();
    if (!trimmed) continue;

    const hookMatch = /HOOK\s*:\s*(.+?)(?=\n\s*(?:BODY|CTA)\s*:)/s.exec(trimmed);
    const bodyMatch = /BODY\s*:\s*(.+?)(?=\n\s*CTA\s*:)/s.exec(trimmed);
    const ctaMatch = /CTA\s*:\s*(.+?)$/s.exec(trimmed);

    if (hookMatch || bodyMatch || ctaMatch) {
      scripts.push({
        hook: hookMatch?.[1]?.trim() ?? "",
        body: bodyMatch?.[1]?.trim() ?? "",
        cta: ctaMatch?.[1]?.trim() ?? "",
      });
    }
  }

  // Fallback: try without SCRIPT markers
  if (scripts.length === 0) {
    const hookMatch = /HOOK\s*:\s*(.+?)(?=\n\s*(?:BODY|CTA)\s*:)/s.exec(raw);
    const bodyMatch = /BODY\s*:\s*(.+?)(?=\n\s*CTA\s*:)/s.exec(raw);
    const ctaMatch = /CTA\s*:\s*(.+?)$/s.exec(raw);
    if (hookMatch || bodyMatch || ctaMatch) {
      scripts.push({
        hook: hookMatch?.[1]?.trim() ?? "",
        body: bodyMatch?.[1]?.trim() ?? "",
        cta: ctaMatch?.[1]?.trim() ?? "",
      });
    }
  }

  return scripts;
}

function parseCaption(raw: string): { caption: string; hashtags: string[] } {
  const captionMatch = /CAPTION\s*:\s*(.+?)(?=\n\s*HASHTAGS)/s.exec(raw);
  const hashtagsMatch = /HASHTAGS\s*:\s*(.+)/s.exec(raw);

  const caption = captionMatch?.[1]?.trim() ?? "";
  const hashtagsRaw = hashtagsMatch?.[1]?.trim() ?? "";

  const hashtags = hashtagsRaw
    .split(/[\s,]+/)
    .filter((t) => t.trim())
    .map((t) => t.trim());

  return { caption, hashtags };
}

function extractCta(raw: string): string {
  const ctaMatches = raw.matchAll(/CTA\s*:\s*(.+)/g);
  for (const match of ctaMatches) {
    return match[1]?.trim() ?? "";
  }
  return "";
}

function extractSection(raw: string, label: string): string {
  const escapedLabel = label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const pattern = new RegExp(
    `${escapedLabel}\\s*:\\s*(.+?)(?=\\n\\s*[A-Z][A-Z ]+:|$)`,
    "s"
  );
  const match = pattern.exec(raw);
  return match?.[1]?.trim() ?? "";
}

function parseVisual(raw: string) {
  return {
    thumbnailText: extractSection(raw, "THUMBNAIL TEXT"),
    editingSuggestions: extractSection(raw, "EDITING SUGGESTIONS"),
    bRollIdeas: parseNumberedList(extractSection(raw, "B-ROLL IDEAS")),
    cameraAngles: extractSection(raw, "CAMERA ANGLES"),
    lightingSuggestions: extractSection(raw, "LIGHTING SUGGESTIONS"),
    musicStyle: extractSection(raw, "MUSIC STYLE"),
  };
}

function parseStrategy(raw: string) {
  const keywords = extractSection(raw, "SEO KEYWORDS")
    .split(/[,\n]/)
    .map((k) => k.trim())
    .filter((k) => k);
  return {
    bestPostingTime: extractSection(raw, "BEST POSTING TIME"),
    seoKeywords: keywords,
    repurposeIdeas: parseNumberedList(extractSection(raw, "REPURPOSE IDEAS")),
  };
}

function parseCrossPlatform(raw: string) {
  return {
    carouselVersion: extractSection(raw, "CAROUSEL VERSION"),
    instagramStoryVersion: extractSection(raw, "INSTAGRAM STORY VERSION"),
    facebookVersion: extractSection(raw, "FACEBOOK VERSION"),
    linkedinVersion: extractSection(raw, "LINKEDIN VERSION"),
    pinterestVersion: extractSection(raw, "PINTEREST VERSION"),
  };
}

// ---------------------------------------------------------------------------
// OpenAI Helper
// ---------------------------------------------------------------------------

async function openAiComplete(
  client: OpenAI,
  systemPromptText: string,
  userPromptText: string,
  maxTokens: number = 2000
): Promise<string> {
  const response = await client.chat.completions.create({
    model: "gpt-4o",
    messages: [
      { role: "system", content: systemPromptText },
      { role: "user", content: userPromptText },
    ],
    temperature: 0.9,
    max_tokens: maxTokens,
  });

  const content = response.choices[0]?.message?.content;
  if (!content || !content.trim()) {
    throw new functions.HttpsError(
      "internal",
      "Empty response from AI — please try again."
    );
  }
  return content.trim();
}

// ---------------------------------------------------------------------------
// Generation helpers
// ---------------------------------------------------------------------------

async function generateFull(
  client: OpenAI,
  req: ContentRequest,
  sys: string
): Promise<GenerationResult> {
  // Run all 7 independent calls in parallel
  const [
    hooksRaw,
    ideasRaw,
    scriptsRaw,
    captionRaw,
    visualRaw,
    strategyRaw,
    crossPlatformRaw,
  ] = await Promise.all([
    openAiComplete(client, sys, viralHooksPrompt(req), 1500),
    openAiComplete(client, sys, videoIdeasPrompt(req), 1200),
    openAiComplete(client, sys, scriptsPrompt(req), 2500),
    openAiComplete(client, sys, captionPrompt(req), 1200),
    openAiComplete(client, sys, visualPrompt(req), 1000),
    openAiComplete(client, sys, strategyPrompt(req), 1000),
    openAiComplete(client, sys, crossPlatformPrompt(req), 2000),
  ]);

  // Parse all results
  const hooks = parseNumberedList(hooksRaw);
  const ideas = parseNumberedList(ideasRaw);
  const scripts = parseScripts(scriptsRaw);
  const captionData = parseCaption(captionRaw);
  const visualData = parseVisual(visualRaw);
  const strategyData = parseStrategy(strategyRaw);
  const crossData = parseCrossPlatform(crossPlatformRaw);

  return {
    viralHooks: hooks,
    videoIdeas: ideas,
    scripts,
    caption: captionData.caption,
    cta: extractCta(scriptsRaw),
    hashtags: captionData.hashtags,
    thumbnailText: visualData.thumbnailText,
    editingSuggestions: visualData.editingSuggestions,
    bRollIdeas: visualData.bRollIdeas,
    cameraAngles: visualData.cameraAngles,
    lightingSuggestions: visualData.lightingSuggestions,
    musicStyle: visualData.musicStyle,
    bestPostingTime: strategyData.bestPostingTime,
    seoKeywords: strategyData.seoKeywords,
    repurposeIdeas: strategyData.repurposeIdeas,
    carouselVersion: crossData.carouselVersion,
    instagramStoryVersion: crossData.instagramStoryVersion,
    facebookVersion: crossData.facebookVersion,
    linkedinVersion: crossData.linkedinVersion,
    pinterestVersion: crossData.pinterestVersion,
    platform: req.platform,
    niche: req.niche,
    goal: req.goal,
    tone: req.tone,
    length: req.length,
  };
}

async function generateDaily(
  client: OpenAI,
  req: ContentRequest
): Promise<GenerationResult> {
  const day = req.dayOfWeek!;
  const dailySys = dailyVariantSystemPrompt(
    req.platform,
    req.tone,
    req.niche,
    day
  );

  const [hooksRaw, scriptRaw, captionRaw] = await Promise.all([
    openAiComplete(client, dailySys, dailyViralHooksPrompt(req), 600),
    openAiComplete(client, dailySys, dailyScriptIdeaPrompt(req), 800),
    openAiComplete(client, dailySys, dailyCaptionPrompt(req), 800),
  ]);

  const hooks = parseNumberedList(hooksRaw);
  const scripts = parseScripts(scriptRaw);
  const captionData = parseCaption(captionRaw);

  return {
    viralHooks: hooks,
    videoIdeas: [],
    scripts,
    caption: captionData.caption,
    cta: scripts.length > 0 ? scripts[0].cta : "",
    hashtags: captionData.hashtags,
    thumbnailText: "",
    editingSuggestions: "",
    bRollIdeas: [],
    cameraAngles: "",
    lightingSuggestions: "",
    musicStyle: "",
    bestPostingTime: "",
    seoKeywords: [],
    repurposeIdeas: [],
    carouselVersion: "",
    instagramStoryVersion: "",
    facebookVersion: "",
    linkedinVersion: "",
    pinterestVersion: "",
    platform: req.platform,
    niche: req.niche,
    goal: req.goal,
    tone: req.tone,
    length: req.length,
  };
}

// ---------------------------------------------------------------------------
// Cloud Function: generateContent
// ---------------------------------------------------------------------------

export const generateContent = functions.onCall(
  {
    cors: true,
    invoker: "public",
  },
  async (request): Promise<GenerationResult> => {
    const req = request.data as ContentRequest;

    // Validate input
    if (!req.platform || !req.niche || !req.goal || !req.tone || !req.length) {
      throw new functions.HttpsError(
        "invalid-argument",
        "Missing required fields: platform, niche, goal, tone, length"
      );
    }

    // Get API key from environment (set via Firebase secrets)
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new functions.HttpsError(
        "internal",
        "OpenAI API key is not configured."
      );
    }

    const client = new OpenAI({ apiKey });

    try {
      // Determine if this is a daily variant request
      if (req.dayOfWeek) {
        return await generateDaily(client, req);
      }
      const sys = systemPrompt(req.platform, req.tone, req.niche);
      return await generateFull(client, req, sys);
    } catch (error) {
      if (error instanceof functions.HttpsError) {
        throw error;
      }

      // Handle OpenAI errors
      if (error instanceof OpenAI.APIError) {
        if (error.status === 401) {
          throw new functions.HttpsError(
            "internal",
            "Invalid OpenAI API key configured on server."
          );
        }
        if (error.status === 429) {
          throw new functions.HttpsError(
            "resource-exhausted",
            "AI rate limit reached. Please wait a moment and try again."
          );
        }
        throw new functions.HttpsError(
          "internal",
          `OpenAI error: ${error.message}`
        );
      }

      throw new functions.HttpsError(
        "internal",
        `Unexpected error: ${(error as Error).message}`
      );
    }
  }
);
