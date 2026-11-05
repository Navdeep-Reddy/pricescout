# Smart Price Aggregator for Grocery and Ride-Hailing Services

A full-stack final year project that compares grocery delivery offers and ride-hailing fares across multiple providers from one web interface.

**Current data mode: demo only.** The app generates clearly labelled sample prices, fares, ratings, and delivery estimates. It does not have live provider feeds, and sample values must not be used to make purchases or travel decisions. The backend is structured so sample adapters can be replaced with provider-approved integrations.

## What Is Included

- FastAPI backend with REST endpoints for grocery search, ride comparison, location search, and search history.
- React + Tailwind UI served from `static/` with no Node build step.
- Provider adapter layer for sample Blinkit, Zepto, Instamart, BigBasket, Uber, Ola, and Rapido results.
- Product photos looked up from Open Food Facts, cached by the local server, and replaced with a local illustration if none is found.
- Item-search links for grocery providers and a route-filled Uber handoff; Ola and Rapido open their official sites.
- Hyderabad ride presets and recognized locations including HITEC City, Banjara Hills, Gachibowli, Charminar, Secunderabad, and RGIA.
- Coupon cards show only verified offers supplied by an authorized integration. The demo has no coupon feed, so it never invents coupon codes.
- In-memory plus SQLite/PostgreSQL-backed TTL caching.
- Search history storage.
- Links to provider product searches and hands Uber routes off to its documented ride flow; other rides open provider websites.
- Mock location search with optional Nominatim fallback.
- Pytest coverage for the core API paths.

## Architecture

```text
React UI in static/
    |
    | REST
    v
FastAPI app
    |
    +-- /api/grocery/search
    +-- /api/rides/compare
    +-- /api/location/search
    +-- /api/history
    |
    +-- Services
    |   +-- grocery_service.py
    |   +-- ride_service.py
    |   +-- cache_service.py
    |   +-- location_service.py
    |   +-- product_images.py
    |
    +-- Provider adapters
    |   +-- grocery: Blinkit, Zepto, Instamart, BigBasket
    |   +-- rides: Uber, Ola, Rapido
    |
    +-- SQLite/PostgreSQL
        +-- cached_responses
        +-- search_history
```

## Project Structure

```text
app/
  main.py
  config.py
  database.py
  models.py
  schemas.py
  providers/
    grocery/
    rides/
  routers/
    grocery.py
    rides.py
    location.py
    history.py
  services/
    cache_service.py
    deep_links.py
    grocery_service.py
    history_service.py
    location_service.py
    ride_service.py
static/
  index.html
  app.js
  styles.css
tests/
  test_api.py
docs/
  architecture.md
  api-spec.md
  deep-linking.md
```

## Quick Start

On Windows, double-click `start.bat`. It creates a local Python environment, installs dependencies, and starts the website. The first run needs internet access to install Python packages. Keep internet access on while using the site because React and Tailwind are loaded from public CDNs.

Or run the commands manually:

```powershell
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Open `http://127.0.0.1:8000`.

## API Examples

Grocery search:

```powershell
curl "http://127.0.0.1:8000/api/grocery/search?query=Milk%201L&pincode=500001"
```

Ride comparison:

```powershell
curl -X POST "http://127.0.0.1:8000/api/rides/compare" `
  -H "Content-Type: application/json" `
  -d "{\"pickup\":\"HITEC City, Hyderabad\",\"destination\":\"Banjara Hills, Hyderabad\",\"vehicle_type\":\"auto\"}"
```

Location search:

```powershell
curl "http://127.0.0.1:8000/api/location/search?q=Whitefield"
```

## Database

Default local database:

```text
sqlite:///./price_aggregator.db
```

Optional PostgreSQL:

```powershell
docker compose up -d
```

Then set:

```text
DATABASE_URL=postgresql+psycopg://priceagg:priceagg@localhost:5432/priceagg
```

## Testing

```powershell
pytest
```

## Live Price Access and Scraping Limits

The included adapters intentionally return sample data. They do not scrape provider apps or claim to provide live prices.

Before enabling real provider prices, obtain an approved API or written permission and implement that provider's adapter. [Blinkit terms](https://blinkit.com/terms) and [BigBasket terms](https://www.bigbasket.com/terms-and-conditions/) restrict automated extraction of product listings and prices. Uber's [price estimates API documentation](https://developer.uber.com/docs/riders/references/api/v1.2/estimates-price-get) says competitive third-party fare comparisons are not allowed under its API terms. Do not bypass login, location gates, CAPTCHAs, rate limits, or anti-bot controls.

Live grocery prices vary by address and account. Ride fares, pickup ETAs, and vehicle availability change in real time and may require provider authorization. The app opens official provider websites so the user can verify availability and finish the order or booking there. It does not book rides, place orders, or process payments.

When an approved integration becomes available, replace the matching class in `app/providers/grocery/` or `app/providers/rides/`, normalize its response into `app/schemas.py`, and keep credentials in environment variables. The provider interfaces and service layer are the integration points; no live provider credentials are included.

Swiggy publishes an Instamart developer integration through its [Builders Club](https://mcp.swiggy.com/builders/developers/); production access requires its application and authentication flow. For other providers, request approved data access from each provider. Uber documents route handoff through [ride-request deep links](https://developer.uber.com/docs/riders/ride-requests/tutorials/deep-links/introduction), but its price-estimate API has restrictions on competitive price comparisons. This project does not bypass provider logins or scrape app pages.

Product images are requested from the [Open Food Facts API](https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/). This source supplies product imagery only; it does not supply the provider prices shown by this project.

Ride distance and time are demo estimates based on simplified route calculations. Optional location search uses Nominatim only when `ENABLE_LIVE_LOCATION=true`; that does not provide live ride fares.
