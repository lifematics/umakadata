import ClipboardJS from 'clipboard/dist/clipboard.min';
import Routes from '../../javascripts/js-routes.js.erb';

import '../../stylesheets/endpoint';

$(function () {
  let $log = $('#log');
  let page = 1;

  let escapeHtml = function (unsafe) {
    if (unsafe === null) return '';

    return unsafe
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  };

  let printHeader = function (object) {
    if (object === null) return '';

    let entries = [];
    for (let [key, value] of Object.entries(object)) {
      entries.push(`${key}: ${value}`);
    }

    return entries.join('\n');
  };

  let printWarning = function (array) {
    if (array === null) return '';

    let html = '<ul>';
    array.forEach(function (x) {
      html += `<li><pre><code>${x}</pre></code></li>`;
    });
    html += '</ul>';

    return html;
  };

  let printException = function (object) {
    if (object === null) return '';

    let html = '<ul>';
    Object.values(object).forEach(function (x) {
      html += `<li><pre><code>${x[0]}</pre></code></li>`;
    });
    html += '</ul>';

    return html;
  };

  let $loadButton = $('#load-more');

  $loadButton.on('click', function () {
    page += 1;
    loadLog(page);
  });

  let drawLog = function (json) {
    $loadButton.removeClass('show');

    json.data.forEach(function (d) {
      let html = '<div class="card log">';
      html += '<div class="card-header">';
      html += `<a class="card-link collapsed" data-toggle="collapse" data-target="#collapse-${d.id}">${d.comment || ''}</a>`;
      html += '</div>';
      html += `<div id="collapse-${d.id}" class="collapse" data-parent="#log">`;
      html += '<div class="card-body">';
      if (d.curl)  {
        html += `<button type="button" class="btn mb-3 copy-query" data-clipboard-text='${d.curl}'><i class="fa fa-clipboard"> Copy CURL Query</button>`;
      }
      html += '<div class="table-wrapper table-responsive">';
      html += '<table class="table table-bordered">';
      html += '<tbody>';
      if (d.warnings && d.warnings.length > 0) {
        html += `<tr><th colspan="2" class="table-warning">Warning</th><td class="table-warning">${printWarning(d.warnings)}</td></tr>`;
      }
      if (d.exceptions && Object.values(d.exceptions).length > 0) {
        html += `<tr><th colspan="2" class="table-danger">Exception</th><td class="table-danger">${printException(d.exceptions)}</td></tr>`;
      }
      html += `<tr><th colspan="2">Elapsed time</th><td>${Math.round(d.elapsed_time * 1000) / 1000.0} [s]</td></tr>`;
      html += `<tr><th rowspan="4" scope="rowgroup">Request</th><th scope="row">Method</th><td><pre><code>${d.request.method || ''}</code></pre></td></tr>`;
      html += `<tr><th scope="row">URL</th><td><pre><code>${d.request.url || ''}</code></pre></td></tr>`;
      html += `<tr><th scope="row">Headers</th><td><pre><code>${printHeader(d.request.headers)}</code></pre></td></tr>`;
      html += `<tr><th scope="row">Body</th><td><pre><code>${escapeHtml(d.request.body)}</code></pre></td></tr>`;
      html += `<tr><th rowspan="4" scope="rowgroup">Response</th><th scope="row">URL</th><td><pre><code>${d.response.url || ''}</code></pre></td></tr>`;
      html += `<tr><th scope="row">Status</th><td><pre><code>${d.response.status || ''}</code></pre></td></tr>`;
      html += `<tr><th scope="row">Headers</th><td><pre><code>${printHeader(d.response.headers)}</code></pre></td></tr>`;
      html += `<tr><th scope="row">Body</th><td><pre><code>${escapeHtml(d.response.body)}</code></pre></td></tr>`;
      html += '</tbody></table></div></div></div></div>';

      $log.append(html);
    });

    if (json.more) {
      $loadButton.addClass('show');
    }
  };

  let loadLog = function (page) {
    $.ajax({
      type: 'GET',
      dataType: 'json',
      contentType: 'application/json; charset=UTF-8',
      url: Routes.endpoint_log_path($log.data('endpoint'), $log.data('name'), {date: $log.data('date'), page: page}),
      timeout: 10000 // 10 sec
      // eslint-disable-next-line no-unused-vars
    }).done(function (json, textStatus, jqXHR) {
      drawLog(json);
    }).fail(function (jqXHR, textStatus, errorThrown) {
      window.alert(`${textStatus}: ${jqXHR.status} ${errorThrown}`);
    });
  };

  loadLog(page);

  new ClipboardJS('.copy-query');
});
