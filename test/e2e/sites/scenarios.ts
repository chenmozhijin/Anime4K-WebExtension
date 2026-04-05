export interface SiteScenarioDescriptor {
  id: string;
  path: string;
  title: string;
  tags: string[];
  frameSelector?: string;
}

type RouteDefinition = {
  scenarioId: string;
  html: string;
};

function pageTemplate(title: string, body: string, script: string = ''): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <style>
    body {
      margin: 0;
      background: #111;
      color: #fff;
      font-family: sans-serif;
    }

    main {
      padding: 24px;
      display: grid;
      gap: 16px;
    }

    video, iframe, .slot {
      display: block;
      width: 480px;
      height: 270px;
      background: #333;
      border: 0;
    }
  </style>
</head>
<body>
  <main>
    <h1>${title}</h1>
    ${body}
  </main>
  <script>
    ${script}
  </script>
</body>
</html>`;
}

const scenarioRoutes = new Map<string, RouteDefinition>();

function registerScenario(
  descriptor: SiteScenarioDescriptor,
  html: string,
  extraRoutes: Record<string, string> = {},
): SiteScenarioDescriptor {
  scenarioRoutes.set(descriptor.path, {
    scenarioId: descriptor.id,
    html,
  });

  Object.entries(extraRoutes).forEach(([path, routeHtml]) => {
    scenarioRoutes.set(path, {
      scenarioId: descriptor.id,
      html: routeHtml,
    });
  });

  return descriptor;
}

export const siteScenarios: SiteScenarioDescriptor[] = [
  registerScenario(
    {
      id: 'plain-html5',
      path: '/sites/plain-html5',
      title: 'Plain HTML5 Video',
      tags: ['@smoke', '@site'],
    },
    pageTemplate(
      'Plain HTML5 Video',
      '<video id="fixture-video" controls muted playsinline></video>',
    ),
  ),
  registerScenario(
    {
      id: 'spa-route',
      path: '/sites/spa-route/allowed',
      title: 'SPA Route Video',
      tags: ['@smoke', '@site'],
    },
    pageTemplate(
      'SPA Route Video',
      `
        <button id="navigate-disallowed" type="button">Navigate</button>
        <div id="app"></div>
      `,
      `
        const app = document.getElementById('app');
        const render = () => {
          const showVideo = location.pathname.endsWith('/allowed');
          app.innerHTML = showVideo
            ? '<video id="fixture-video" controls muted playsinline></video>'
            : '<div class="slot" id="empty-slot">No video on this route</div>';
        };
        render();
        window.addEventListener('popstate', render);
        document.getElementById('navigate-disallowed').addEventListener('click', () => {
          history.pushState({}, '', '/sites/spa-route/disallowed');
          render();
        });
      `,
    ),
    {
      '/sites/spa-route/disallowed': pageTemplate(
        'SPA Route Without Video',
        '<div class="slot" id="empty-slot">No video on this route</div>',
      ),
    },
  ),
  registerScenario(
    {
      id: 'shadow-dom',
      path: '/sites/shadow-dom',
      title: 'Open Shadow DOM Video',
      tags: ['@smoke', '@site'],
    },
    pageTemplate(
      'Open Shadow DOM Video',
      '<div id="shadow-slot" class="slot">Shadow video pending</div>',
      `
        // Fixture models only content-script-visible DOM. Closed shadow roots are intentionally excluded.
        setTimeout(() => {
          const host = document.createElement('div');
          host.id = 'shadow-host';
          const shadow = host.attachShadow({ mode: 'open' });
          shadow.innerHTML = '<video id="shadow-video" controls muted playsinline></video>';
          document.getElementById('shadow-slot').replaceWith(host);
        }, 150);
      `,
    ),
  ),
  registerScenario(
    {
      id: 'delayed-video',
      path: '/sites/delayed-video',
      title: 'Delayed Video',
      tags: ['@site'],
    },
    pageTemplate(
      'Delayed Video',
      '<div id="delayed-slot" class="slot">Video will be inserted</div>',
      `
        setTimeout(() => {
          document.getElementById('delayed-slot').outerHTML = '<video id="delayed-video" controls muted playsinline></video>';
        }, 350);
      `,
    ),
  ),
  registerScenario(
    {
      id: 'iframe-video',
      path: '/sites/iframe-video',
      title: 'Iframe Video',
      tags: ['@site'],
      frameSelector: '#scenario-frame',
    },
    pageTemplate(
      'Iframe Video',
      '<iframe id="scenario-frame" title="scenario frame" src="/sites/iframe-video/embed"></iframe>',
    ),
    {
      '/sites/iframe-video/embed': pageTemplate(
        'Iframe Inner Video',
        '<video id="iframe-video" controls muted playsinline></video>',
      ),
    },
  ),
];

export function getSiteScenario(id: string): SiteScenarioDescriptor {
  const scenario = siteScenarios.find(candidate => candidate.id === id);
  if (!scenario) {
    throw new Error(`Unknown site scenario: ${id}`);
  }
  return scenario;
}

export function resolveScenarioRoute(pathname: string): RouteDefinition | null {
  return scenarioRoutes.get(pathname) ?? null;
}
