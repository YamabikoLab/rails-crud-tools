function showCrudFileSyncMessage() {
    const message = document.createElement('div');
    message.id = 'crud-file-sync-message';
    message.innerText = 'CRUD File Synchronizing...';
    message.style.position = 'fixed';
    message.style.top = '10px';
    message.style.right = '10px';
    message.style.backgroundColor = 'yellow';
    message.style.padding = '10px';
    message.style.zIndex = '1000';
    document.body.appendChild(message);
}

function hideCrudFileSyncMessage() {
    const message = document.getElementById('crud-file-sync-message');
    if (message) {
        document.body.removeChild(message);
    }
}