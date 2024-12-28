function showCrudFileReloadMessage() {
    const message = document.createElement('div');
    message.id = 'rails-crud-reload-message';
    message.innerText = 'CRUD File Reloading...';
    message.style.position = 'fixed';
    message.style.top = '50%';
    message.style.left = '50%';
    message.style.transform = 'translate(-50%, -50%)';
    message.style.backgroundColor = '#333';
    message.style.color = '#fff';
    message.style.padding = '20px';
    message.style.borderRadius = '8px';
    message.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.1)';
    message.style.zIndex = '1000';
    document.body.appendChild(message);
}

function hideCrudFileReloadMessage() {
    const message = document.getElementById('rails-crud-reload-message');
    if (message) {
        document.body.removeChild(message);
    }
}

// ジョブ実行中のメッセージを表示
function showJobMessage() {
    const overlay = document.createElement('div');
    overlay.id = 'rails-crud-job-message-overlay';
    overlay.style.position = 'fixed';
    overlay.style.top = '0';
    overlay.style.left = '0';
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    overlay.style.backgroundColor = 'rgba(0, 0, 0, 0.5)';
    overlay.style.zIndex = '999';
    overlay.style.display = 'flex';
    overlay.style.justifyContent = 'center';
    overlay.style.alignItems = 'center';

    const message = document.createElement('div');
    message.id = 'rails-crud-job-message';
    message.innerText = 'Job is running. Please do not operate the screen.';
    message.style.backgroundColor = '#333';
    message.style.color = '#fff';
    message.style.padding = '20px';
    message.style.borderRadius = '8px';
    message.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.1)';

    overlay.appendChild(message);
    document.body.appendChild(overlay);
}

// ジョブ実行中のメッセージを非表示
function hideJobMessage() {
    const overlay = document.getElementById('rails-crud-job-message-overlay');
    if (overlay) {
        document.body.removeChild(overlay);
    }
}