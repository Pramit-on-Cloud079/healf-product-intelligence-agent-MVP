# Healf Product Intelligence Agent MVP
Built by Pramit Dasgupta
---
## Overview
This project is a functional MVP of a conversational Product Intelligence Agent built for Healf.
The agent accepts:
- a live Healf product page URL
- a natural language question
It then:
1. fetches the live product page
2. extracts structured product intelligence
3. evaluates the page using an LLM
4. returns grounded structured responses
5. logs executions and failures into Supabase
The workflow is designed as a modular AI-native architecture that can evolve into a production-grade ecommerce intelligence system.
---
# Live MVP
## Hosted Demo
https://healf-intel-agent-by-pramit.netlify.app/

Anyone can test the workflow by:
1. pasting a live Healf product URL
2. asking a natural language question
3. receiving a grounded structured response generated from live product data
---
# Assignment Objectives
The MVP was designed to satisfy the core capabilities outlined in the assignment.
| Capability | Implementation |
|---|---|
| Navigate | Fetches live Healf product pages through webhook + HTTP request |
| Ingest | Extracts structured data, product text, reviews, metadata, and image signals |
| Evaluate | Uses GPT-4.1 Mini to reason over extracted product intelligence |
| Act on findings | Returns grounded answers, evidence, missing data, and recommendations |
---
# High-Level Architecture
```text
Webhook
   ↓
Validate + Normalize Input
   ↓
Fetch Page HTML
   ↓
Extract Page Signals
   ↓
LLM Engine
   ↓
Normalize Output
   ↓
Respond + Persist
```

The architecture intentionally separates:
    • extraction from reasoning 
    • success handling from failure handling 
    • response generation from persistence 
This improves:
    • grounding quality 
    • observability 
    • extensibility 
    • debugging 
    • production readiness 

# Database Schema

The Supabase persistence schema is included under:

```text
/database/supabase_schema.sql
```

The schema stores:
- extracted product intelligence
- AI responses
- evidence and reasoning
- workflow execution metadata
- failure states
- evaluation telemetry

This was designed to support:
- observability
- debugging
- analytics
- future evaluation pipelines
- potential fine-tuning datasets

## Workflow Components
1. Webhook
Accepts:
    • product URL 
    • natural language question 
Example Request
{
  "url": "https://healf.com/products/lmnt-recharge-electrolytes-variety-pack",
  "question": "Does this product actually have customer reviews or is the page just mentioning reviews somewhere?"
}

2. Validate + Normalize Input
Responsibilities
    • validates request shape 
    • normalizes URLs 
    • extracts Shopify product handle 
    • extracts domain information 
Why this matters
    • prevents malformed downstream processing 
    • standardizes product references 
    • improves workflow reliability 
Input validation for missing fields is assumed to be handled at the form/request layer.

3. Fetch Page HTML
Fetches the live Healf product page using browser-like request headers.
Implementation details
    • browser-style headers 
    • redirect handling 
    • raw HTML retrieval 
    • retry support 
    • graceful failure handling 

4. Extract Page Signals
This is the primary ingestion and intelligence extraction layer.
Product Metadata Extraction
    • title 
    • meta description 
    • canonical URL 
    • OG image 
Structured Data Extraction
    • JSON-LD parsing 
    • Product schema 
    • Review schema 
    • AggregateRating schema 
Review Intelligence
    • review presence detection 
    • review count extraction 
    • rating extraction 
    • aggregate rating parsing 
    • review schema parsing 
    • review mention analysis 
Content Extraction
    • page text extraction 
    • headings 
    • lists 
    • content sections 
    • structured content blocks 
Image Signal Extraction
    • image URL extraction 
    • OG image extraction 
    • Next.js image normalization 
Page Quality Signals
    • schema availability 
    • section counts 
    • text density 
    • image counts 
Why this architecture was chosen
    • separates extraction from reasoning 
    • reduces hallucination risk 
    • improves grounding quality 
    • reduces token waste 
    • makes future extensions easier 

## LLM Evaluation Layer
The reasoning layer uses GPT-4.1 Mini.
The model:
    • answers questions using only extracted data 
    • avoids unsupported claims 
    • identifies missing information 
    • generates recommendations 
    • classifies question types 
    • returns structured JSON 
Supported question types
    • ingredient_check 
    • reviews_check 
    • page_quality_review 
    • seo_review 
    • pricing_check 
    • subscription_check 
    • product_summary 
    • comparison 
    • general_question 
    • other 
Prompt design goals
    • reduce hallucinations 
    • separate facts from inference 
    • avoid exposing implementation details 
    • encourage grounded reasoning 
    • explicitly acknowledge uncertainty when information is incomplete 

## Runtime Failure Handling
The workflow includes dedicated failure branches for:
    • page fetch failures 
    • LLM execution failures 
    • malformed model output 
Failures are converted into structured JSON responses instead of crashing the workflow.
All failed executions are logged into Supabase for:
    • debugging 
    • observability 
    • future evaluation datasets 
This was intentionally added so the MVP behaves more like a resilient system rather than a linear demo workflow.

## Output Format
Responses are normalized into structured JSON.
Example
{
  "success": true,
  "answer": "The product includes customer reviews with an average rating of 4.9 from 445 reviews.",
  "confidence": "high",
  "evidence": [
    "The extracted review data indicates active customer reviews.",
    "The page includes structured AggregateRating schema."
  ],
  "missing_data": [],
  "improvement_suggestions": [
    "Display review excerpts directly on the page."
  ],
  "question_type": "reviews_check",
  "can_answer_directly": true
}
This structure makes the output reusable by:
    • APIs 
    • dashboards 
    • operator tools 
    • analytics pipelines 
    • evaluation systems 

## Persistence Layer
All workflow runs are stored in Supabase.
Stored data includes
    • user question 
    • URL 
    • extracted product data 
    • metadata 
    • AI responses 
    • evidence 
    • confidence 
    • recommendations 
    • execution metadata 
    • workflow failures 
Why this matters
    • observability 
    • debugging 
    • analytics 
    • evaluation benchmarking 
    • future fine-tuning datasets 
Both successful and failed executions are persisted for traceability.

## Example Questions Supported
Reviews and Trust
    • Does this product have any reviews? 
    • What evidence suggests customers trust this product? 
    • Would you consider this page high trust for a first-time buyer? 
Product Intelligence
    • Does this product contain Vitamin D? 
    • Does this contain artificial sweeteners, gums, fillers, or preservatives? 
    • Is this suitable for a keto diet? 
Page Evaluation
    • What are the biggest SEO weaknesses of this page? 
    • What information is missing from this PDP? 
    • What would improve conversion? 
Missing Information / Confidence
    • What cannot be determined from this page? 
    • Is there enough information to answer confidently? 

Example Outputs
Example 1 — Review Detection
Question
Does this product actually have customer reviews or is the page just mentioning reviews somewhere?
Result
    • detected 445 reviews 
    • identified aggregate rating of 4.9 
    • detected structured review schema 
    • classified as reviews_check 
    • returned grounded evidence 

Example 2 — Ingredient Validation
Question
Does this product contain any artificial sweeteners, gums, fillers, or preservatives?
Result
    • analyzed extracted ingredient lists 
    • identified stevia and natural flavoring references 
    • avoided unsupported ingredient claims 
    • returned evidence-backed reasoning 

Example 3 — SEO Evaluation
Question
What are the 5 biggest weaknesses of this product page from an SEO perspective?
Result
    • identified content quality issues 
    • identified weak review visibility 
    • identified image URL problems 
    • identified content loading placeholders 
    • generated actionable SEO recommendations 

Example 4 — Missing Data Handling
Question
What is the exact amount of magnesium per serving?
Result
    • correctly identified missing nutritional detail 
    • refused to hallucinate dosage information 
    • lowered confidence appropriately 
    • surfaced missing-data explanations 
This was an important evaluation scenario because it tests hallucination resistance and uncertainty handling.

## Key Design Decisions
Why structured extraction before the LLM?
Instead of sending raw HTML directly into the model, the workflow first extracts:
    • structured schemas 
    • product metadata 
    • review signals 
    • content sections 
    • image signals 
Benefits
    • lower token usage 
    • better grounding 
    • improved consistency 
    • easier debugging 
    • reduced hallucination risk 

Why prioritize JSON-LD?
Modern ecommerce storefronts often expose valuable product intelligence through JSON-LD.
This provides:
    • reliable review counts 
    • explicit ratings 
    • structured product metadata 
    • cleaner ingestion than raw scraping alone 

Why normalize outputs?
The normalization layer ensures:
    • stable API responses 
    • easier integrations 
    • cleaner persistence 
    • future analytics compatibility 
    • evaluation pipeline support 

## Current MVP Limitations
This MVP intentionally prioritizes architecture and reasoning quality over breadth.
Current limitations
    • no browser automation for interactive page states 
    • image URLs are ingested and normalized, but raw multimodal image understanding is not yet implemented 
    • no vector search or embeddings 
    • no cross-product memory 
    • no catalog-wide benchmarking 
    • no review sentiment analysis 
    • limited SEO scoring framework 
    • no formal ranking/scoring engine 

## What I Would Add Next
1. Vision-Based Image Understanding
Add multimodal image analysis for:
    • packaging quality 
    • product clarity 
    • trust signal analysis 
    • lifestyle imagery analysis 
    • visual consistency 

2. Advanced Review Intelligence
Add:
    • sentiment analysis 
    • review summarization 
    • complaint clustering 
    • recurring issue detection 

3. PDP Quality Scoring
Add scoring for:
    • SEO completeness 
    • trust signals 
    • schema quality 
    • content depth 
    • conversion readiness 

4. Shopify-Native Structured APIs
Where available, use Shopify structured endpoints directly in addition to HTML extraction.
Benefits
    • cleaner data 
    • faster processing 
    • reduced parsing complexity 
    • improved reliability 

5. Evaluation & Telemetry Layer
Add:
    • answer quality scoring 
    • confidence calibration 
    • parse success metrics 
    • workflow reliability analytics 
    • automated evaluation datasets 

## What This Could Become in 3 Months
A production-grade ecommerce intelligence system capable of:
    • automated PDP audits 
    • conversion optimization recommendations 
    • trust signal analysis 
    • SEO intelligence 
    • review intelligence 
    • category benchmarking 
    • AI-assisted content generation 
    • merchandising insights 
    • catalog-wide monitoring 
Potential integrations
    • Slack 
    • internal operator dashboards 
    • CMS systems 
    • merchandising tooling 
    • QA pipelines 
    • analytics systems 

Tech Stack
    • n8n 
    • OpenAI GPT-4.1 Mini 
    • Supabase 
    • JavaScript 
    • Shopify storefront data 

## Repository Structure
/
├── README.md
├── workflow/
│   └── healf-product-intelligence-agent.json
├── screenshots/
│   ├── workflow.png
│   ├── reviews-example.png
│   ├── seo-example.png
│   ├── trust-example.png
│   └── missing-data-example.png

Files Included
    • n8n workflow export JSON 
    • README 
    • workflow screenshot 
    • example outputs 
    • live hosted MVP 

## Conclusion
This MVP demonstrates a scalable approach to ecommerce product intelligence using:
    • structured extraction 
    • grounded reasoning 
    • modular workflow orchestration 
    • runtime failure handling 
    • execution logging 
The focus was not just on answering questions, but on building a strong architectural foundation that can evolve into a production-grade AI operating system for ecommerce intelligence.
A publicly accessible hosted MVP was also deployed to demonstrate the workflow operating against live Healf product pages in real time.
