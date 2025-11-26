#!/usr/bin/env python3
"""Quick test if Gemini API key works"""
import os
import sys

try:
    import google.generativeai as genai
    print("✅ google-generativeai package installed")
except ImportError:
    print("❌ Need to install: pip install google-generativeai")
    sys.exit(1)

api_key = os.environ.get('GEMINI_API_KEY')
if not api_key:
    print("❌ Set GEMINI_API_KEY environment variable")
    sys.exit(1)

try:
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-1.5-flash')
    response = model.generate_content("Say hello in Russian")
    print("✅ API key works!")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"❌ API error: {e}")
    sys.exit(1)
