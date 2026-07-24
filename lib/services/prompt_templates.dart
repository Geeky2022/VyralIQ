/// Prompt engineering for VyralIQ.
/// All prompts are designed to produce the "Creative Director" voice:
/// confident, professional, strategic, encouraging, never generic.

class PromptTemplates {
  /// The base system prompt that establishes the VyralIQ Creative Director
  /// persona.
  static String systemPrompt({
    required String platform,
    required String tone,
    required String niche,
  }) =>
      '''You are an expert Creative Director and social media strategist at VyralIQ, a premium AI content studio. You create content for $platform. Your tone is $tone. Your writing is strategic, engaging, and tailored for the $niche niche. You never produce generic content — every output feels handcrafted by a professional agency. You think like a storyteller, strategist, and brand builder. Your responses should feel like they came from a top-tier creative agency, not a chatbot. Be specific, actionable, and original. Avoid clichés and filler.''';

  // ---------------------------------------------------------------------------
  // Viral Hooks
  // ---------------------------------------------------------------------------
  static String viralHooksPrompt({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) =>
      '''Generate exactly 25 scroll-stopping viral hooks for $platform in the $niche niche.
Goal: $goal. Tone: $tone. Content length style: $length.

Requirements:
- Each hook must be a single compelling sentence
- Vary the hook styles: curiosity gaps, bold statements, controversial takes, questions, pattern interrupts, listicles, "how to" hooks
- Make them platform-native (e.g. fast cuts for TikTok, professional polish for LinkedIn)
- Number them 1–25
- Return ONLY the numbered list, no preamble.''';

  // ---------------------------------------------------------------------------
  // Video Ideas
  // ---------------------------------------------------------------------------
  static String videoIdeasPrompt({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) =>
      '''Generate exactly 10 unique video content ideas for $platform in the $niche niche.
Goal: $goal. Tone: $tone. Content length style: $length.

Requirements:
- Each idea should include a strong concept/title and a 1–2 sentence description
- Make them original — nothing generic like "day in the life"
- Tailor to $platform's format (vertical short-form, horizontal long-form, etc.)
- Number them 1–10
- Return ONLY the numbered list.''';

  // ---------------------------------------------------------------------------
  // Scripts
  // ---------------------------------------------------------------------------
  static String scriptsPrompt({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) =>
      '''Generate exactly 5 complete video scripts for $platform in the $niche niche.
Goal: $goal. Tone: $tone. Content length style: $length.

For each script, provide exactly 3 sections labeled HOOK, BODY, and CTA.

Requirements:
- HOOK: 1–2 gripping opening lines designed to stop the scroll immediately
- BODY: The main content — substantive, well-structured, value-packed. Adapt length to "$length" style.
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

(Continue for all 5 scripts)''';

  // ---------------------------------------------------------------------------
  // Caption
  // ---------------------------------------------------------------------------
  static String captionPrompt({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) =>
      '''Write one expertly crafted social media caption for $platform in the $niche niche.
Goal: $goal. Tone: $tone. Content length style: $length.

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
[hashtags listed space-separated]''';

  // ---------------------------------------------------------------------------
  // Thumbnail & Visual
  // ---------------------------------------------------------------------------
  static String visualPrompt({
    required String platform,
    required String niche,
    required String tone,
  }) =>
      '''You are a visual creative director. Provide production guidance for a $platform video in the $niche niche with a $tone tone.

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
[A specific music genre or vibe recommendation]''';

  // ---------------------------------------------------------------------------
  // SEO & Strategy
  // ---------------------------------------------------------------------------
  static String strategyPrompt({
    required String platform,
    required String niche,
    required String goal,
  }) =>
      '''You are a social media strategist. Provide optimization guidance for $platform in the $niche niche with the goal of $goal.

Provide exactly:

BEST POSTING TIME:
[One recommended time/day with brief reasoning]

SEO KEYWORDS:
[A comma-separated list of 10 relevant high-volume keywords]

REPURPOSE IDEAS:
[A list of 5 specific ways to repurpose this content across other platforms]''';

  // ---------------------------------------------------------------------------
  // Cross-Platform Versions
  // ---------------------------------------------------------------------------
  static String crossPlatformPrompt({
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) =>
      '''You are a cross-platform content strategist. Take the core content idea for the $niche niche (goal: $goal, tone: $tone, length: $length) and adapt it for:

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

Be specific — give actionable copy, not vague suggestions.''';

  // ---------------------------------------------------------------------------
  // Weekly variant prompt — adds a slight "day-of-week" twist
  // ---------------------------------------------------------------------------
  static String dailyVariantSystemPrompt({
    required String platform,
    required String tone,
    required String niche,
    required String dayOfWeek,
  }) =>
      '''You are an expert Creative Director and social media strategist at VyralIQ, a premium AI content studio. You create content for $platform. Your tone is $tone. Your writing is strategic, engaging, and tailored for the $niche niche. Today is $dayOfWeek. Weave the energy and vibe of $dayOfWeek naturally into the content — but don't make it the focal point. Never generic. Every output feels handcrafted by a professional agency.''';

  static String dailyViralHooksPrompt({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
    required String dayOfWeek,
  }) =>
      '''Generate exactly 3 compelling viral hooks for a $dayOfWeek post on $platform in the $niche niche.
Goal: $goal. Tone: $tone.

Let the $dayOfWeek energy subtly influence the hooks. Number them 1–3. Return ONLY the numbered list.''';

  static String dailyScriptIdeaPrompt({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String dayOfWeek,
  }) =>
      '''Generate one complete script idea for a $dayOfWeek post on $platform in the $niche niche.
Goal: $goal. Tone: $tone.

Provide:
HOOK: ...
BODY: ...
CTA: ...

Let the $dayOfWeek energy subtly influence the tone. Return ONLY the formatted script.''';

  static String dailyCaptionPrompt({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String dayOfWeek,
  }) =>
      '''Write a caption for a $dayOfWeek post on $platform in the $niche niche.
Goal: $goal. Tone: $tone.

Provide:
CAPTION:
[the caption]

HASHTAGS:
[8-10 relevant hashtags]

Let $dayOfWeek energy subtly influence the copy.''';
}
