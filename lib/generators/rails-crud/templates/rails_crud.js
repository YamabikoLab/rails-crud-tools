function showCrudFileReloadMessage() {
    const message = document.createElement('div');
    message.id = 'crud-file-reload-message';
    message.innerText = 'CRUD File Reloading...';
    message.style.position = 'fixed';
    message.style.top = '10px';
    message.style.right = '10px';
    message.style.backgroundColor = 'yellow';
    message.style.padding = '10px';
    message.style.zIndex = '1000';
    document.body.appendChild(message);
}

function hideCrudFileSyncMessage() {
    const message = document.getElementById('crud-file-reload-message');
    if (message) {
        document.body.removeChild(message);
    }
}


// ジョブ実行中のメッセージを表示
function showJobMessage() {
    const overlay = document.createElement('div');
    overlay.id = 'job-message-overlay';
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
    message.id = 'job-message';
    message.innerText = 'Job is running. Please do not operate the screen.';
    message.style.backgroundColor = 'yellow';
    message.style.padding = '20px';
    message.style.borderRadius = '5px';
    message.style.boxShadow = '0 0 10px rgba(0, 0, 0, 0.5)';

    overlay.appendChild(message);
    document.body.appendChild(overlay);
}

// ジョブ実行中のメッセージを非表示
function hideJobMessage() {
    const overlay = document.getElementById('job-message-overlay');
    if (overlay) {
        document.body.removeChild(overlay);
    }
}